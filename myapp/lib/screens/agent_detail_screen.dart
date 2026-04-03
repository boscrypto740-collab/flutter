import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agent_model.dart';
import '../services/rating_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/rating_stars.dart';

class AgentDetailScreen extends StatefulWidget {
  final AgentModel agent;
  const AgentDetailScreen({super.key,required this.agent});
  @override State<AgentDetailScreen> createState()=>_AgentDetailScreenState();
}

class _AgentDetailScreenState extends State<AgentDetailScreen> {
  bool _isRenting=false,_hasRented=false,_hasReviewed=false;
  final _rs=RatingService();

  @override void initState(){super.initState();_check();}

  Future<void> _check() async {
    final u=FirebaseAuth.instance.currentUser;
    if(u==null||widget.agent.id==null)return;
    final r=await _rs.hasReviewed(widget.agent.id!,u.uid);
    setState(()=>_hasReviewed=r);
  }

  Future<void> _rent() async {
    final u=FirebaseAuth.instance.currentUser;
    if(u==null)return;
    setState(()=>_isRenting=true);
    try {
      await FirebaseFirestore.instance.collection('rentals').add({'agentId':widget.agent.id,'agentTitle':widget.agent.title,'agentOwnerId':widget.agent.userId,'renterId':u.uid,'renterEmail':u.email,'pricePerRun':widget.agent.pricePerRun,'status':'active','rentedAt':DateTime.now().toIso8601String()});
      await FirebaseFirestore.instance.collection('agents').doc(widget.agent.id).update({'totalRuns':FieldValue.increment(1)});
      setState(()=>_hasRented=true);
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Agent rented!'),backgroundColor:AppColors.online));
    } catch(e){
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Failed. Try again.'),backgroundColor:Colors.redAccent));
    }
    setState(()=>_isRenting=false);
  }

  void _showReview(){
    double sel=5; final ctrl=TextEditingController();
    showDialog(context:context,builder:(_)=>Dialog(
      backgroundColor:AppColors.bgCard,
      shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)),
      child:Padding(padding:const EdgeInsets.all(20),child:Column(mainAxisSize:MainAxisSize.min,children:[
        const Text('Rate this agent',style:TextStyle(color:AppColors.textPrimary,fontSize:16,fontWeight:FontWeight.w500)),
        const SizedBox(height:16),
        InteractiveRatingStars(initialRating:5,onRatingChanged:(r)=>sel=r),
        const SizedBox(height:16),
        TextField(controller:ctrl,style:const TextStyle(color:AppColors.textPrimary),maxLines:3,
          decoration:const InputDecoration(hintText:'Write your review...',hintStyle:TextStyle(color:AppColors.textMuted))),
        const SizedBox(height:16),
        Row(children:[
          Expanded(child:TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel',style:TextStyle(color:AppColors.textMuted)))),
          const SizedBox(width:8),
          Expanded(child:ElevatedButton(
            onPressed:() async {
              final u=FirebaseAuth.instance.currentUser!;
              await _rs.submitReview(agentId:widget.agent.id!,userId:u.uid,userEmail:u.email??'',rating:sel,comment:ctrl.text.trim());
              setState(()=>_hasReviewed=true);
              if(mounted){Navigator.pop(context);ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Review submitted!'),backgroundColor:AppColors.online));}
            },
            child:const Text('Submit'))),
        ]),
      ]))));
  }

  @override
  Widget build(BuildContext context){
    final a=widget.agent;
    final u=FirebaseAuth.instance.currentUser;
    final isOwner=u?.uid==a.userId;
    final icons={'Research':Icons.manage_search_rounded,'Code':Icons.code_rounded,'Data':Icons.bar_chart_rounded,'Writing':Icons.edit_note_rounded,'Other':Icons.auto_awesome_rounded};
    final icon=icons[a.category]??Icons.auto_awesome_rounded;

    return Scaffold(
      appBar:AppBar(
        leading:IconButton(icon:const Icon(Icons.arrow_back_rounded,color:AppColors.textSecondary),onPressed:()=>Navigator.pop(context)),
        title:const AppLogoWithText(),
        actions:[
          if(!isOwner)TextButton.icon(onPressed:_hasReviewed?null:_showReview,
            icon:Icon(_hasReviewed?Icons.check_circle_rounded:Icons.rate_review_rounded,size:16,color:_hasReviewed?AppColors.online:AppColors.accent),
            label:Text(_hasReviewed?'Reviewed':'Review',style:TextStyle(color:_hasReviewed?AppColors.online:AppColors.accent,fontSize:12))),
          if(isOwner)Container(margin:const EdgeInsets.only(right:12),padding:const EdgeInsets.symmetric(horizontal:10,vertical:5),
            decoration:BoxDecoration(color:AppColors.accentDark,borderRadius:BorderRadius.circular(8),border:Border.all(color:AppColors.primary,width:.5)),
            child:const Text('Your agent',style:TextStyle(color:AppColors.accentLight,fontSize:11,fontWeight:FontWeight.w500))),
        ],
      ),
      body:SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Container(margin:const EdgeInsets.all(16),padding:const EdgeInsets.all(20),
          decoration:BoxDecoration(color:AppColors.bgCard,borderRadius:BorderRadius.circular(16),border:Border.all(color:AppColors.bgCardBorder,width:.5)),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Row(children:[
              Container(width:56,height:56,decoration:BoxDecoration(color:AppColors.accentDark,borderRadius:BorderRadius.circular(14)),
                child:Icon(icon,color:AppColors.accent,size:26)),
              const SizedBox(width:14),
              Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text(a.title,style:const TextStyle(color:AppColors.textPrimary,fontSize:18,fontWeight:FontWeight.w500)),
                const SizedBox(height:6),
                Row(children:[RatingStars(rating:a.rating,size:14),const SizedBox(width:6),Text(a.rating.toStringAsFixed(1),style:const TextStyle(color:AppColors.textSecondary,fontSize:12))]),
              ])),
            ]),
            const SizedBox(height:16),
            Row(children:[
              _Chip(icon:Icons.play_circle_rounded,value:'${a.totalRuns}',label:'Runs',color:AppColors.accent),
              const SizedBox(width:10),
              _Chip(icon:Icons.attach_money_rounded,value:'\$${a.pricePerRun.toStringAsFixed(2)}',label:'Per run',color:AppColors.online),
              const SizedBox(width:10),
              _Chip(icon:Icons.category_rounded,value:a.category,label:'Category',color:AppColors.accentLight),
            ]),
          ])),
        Padding(padding:const EdgeInsets.fromLTRB(16,0,16,16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('About',style:TextStyle(color:AppColors.textPrimary,fontSize:15,fontWeight:FontWeight.w500)),
          const SizedBox(height:8),
          Text(a.description,style:const TextStyle(color:AppColors.textSecondary,fontSize:14,height:1.6)),
          const SizedBox(height:20),
          Row(children:[
            const Text('Reviews',style:TextStyle(color:AppColors.textPrimary,fontSize:15,fontWeight:FontWeight.w500)),
            const Spacer(),
            if(!isOwner&&!_hasReviewed)GestureDetector(onTap:_showReview,child:Container(
              padding:const EdgeInsets.symmetric(horizontal:10,vertical:5),
              decoration:BoxDecoration(color:AppColors.accentDark,borderRadius:BorderRadius.circular(8),border:Border.all(color:AppColors.primary,width:.5)),
              child:const Text('Write review',style:TextStyle(color:AppColors.accentLight,fontSize:11)))),
          ]),
          const SizedBox(height:10),
          StreamBuilder<List<Map<String,dynamic>>>(
            stream:a.id!=null?_rs.getReviews(a.id!):const Stream.empty(),
            builder:(context,snap){
              if(snap.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator(color:AppColors.accent,strokeWidth:2));
              final reviews=snap.data??[];
              if(reviews.isEmpty)return Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:AppColors.bgCard,borderRadius:BorderRadius.circular(12),border:Border.all(color:AppColors.bgCardBorder,width:.5)),child:const Center(child:Text('No reviews yet.',style:TextStyle(color:AppColors.textMuted,fontSize:13))));
              return Column(children:reviews.map((r)=>Container(
                margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(14),
                decoration:BoxDecoration(color:AppColors.bgCard,borderRadius:BorderRadius.circular(12),border:Border.all(color:AppColors.bgCardBorder,width:.5)),
                child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Row(children:[
                    Container(width:28,height:28,decoration:BoxDecoration(color:AppColors.accentDark,borderRadius:BorderRadius.circular(8)),
                      child:Center(child:Text((r['userEmail'] as String).substring(0,1).toUpperCase(),style:const TextStyle(color:AppColors.accent,fontSize:12,fontWeight:FontWeight.w500)))),
                    const SizedBox(width:8),
                    Expanded(child:Text(r['userEmail']??'',style:const TextStyle(color:AppColors.textSecondary,fontSize:12),overflow:TextOverflow.ellipsis)),
                    RatingStars(rating:(r['rating']??0.0).toDouble(),size:12),
                  ]),
                  if((r['comment'] as String).isNotEmpty)...[const SizedBox(height:8),Text(r['comment'],style:const TextStyle(color:AppColors.textPrimary,fontSize:13,height:1.4))],
                ]))).toList());
            }),
          const SizedBox(height:20),
        ])),
      ])),
      bottomNavigationBar:isOwner?null:Container(
        padding:const EdgeInsets.fromLTRB(16,12,16,28),
        decoration:const BoxDecoration(color:AppColors.bgDeep,border:Border(top:BorderSide(color:AppColors.bgCardBorder,width:.5))),
        child:_hasRented
          ?Container(padding:const EdgeInsets.symmetric(vertical:14),decoration:BoxDecoration(color:AppColors.onlineDark,borderRadius:BorderRadius.circular(12),border:Border.all(color:AppColors.online,width:.5)),
              child:const Row(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.check_circle_rounded,color:AppColors.online,size:18),SizedBox(width:8),Text('Agent rented — active',style:TextStyle(color:AppColors.online,fontSize:15,fontWeight:FontWeight.w500))]))
          :ElevatedButton.icon(
              onPressed:_isRenting?null:_rent,
              icon:_isRenting?const SizedBox(width:16,height:16,child:CircularProgressIndicator(color:AppColors.accentLight,strokeWidth:2)):const Icon(Icons.bolt_rounded,size:18),
              label:Text(_isRenting?'Processing...':'Rent agent — \$${a.pricePerRun.toStringAsFixed(2)}/run',style:const TextStyle(fontSize:15))),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon; final String value,label; final Color color;
  const _Chip({required this.icon,required this.value,required this.label,required this.color});
  @override
  Widget build(BuildContext context)=>Expanded(child:Container(
    padding:const EdgeInsets.symmetric(vertical:10),
    decoration:BoxDecoration(color:AppColors.bgDeep,borderRadius:BorderRadius.circular(10),border:Border.all(color:AppColors.bgCardBorder,width:.5)),
    child:Column(children:[Icon(icon,color:color,size:18),const SizedBox(height:4),Text(value,style:TextStyle(color:color,fontSize:12,fontWeight:FontWeight.w500),maxLines:1,overflow:TextOverflow.ellipsis),Text(label,style:const TextStyle(color:AppColors.textMuted,fontSize:10))])));
}
