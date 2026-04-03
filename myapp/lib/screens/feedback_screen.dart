import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override State<FeedbackScreen> createState()=>_FeedbackScreenState();
}
class _FeedbackScreenState extends State<FeedbackScreen> {
  final _subCtrl=TextEditingController();
  final _msgCtrl=TextEditingController();
  String _type='General';
  bool _loading=false,_submitted=false;
  final _types=['General','Bug report','Feature request','Billing','Other'];

  Future<void> _submit() async {
    if(_subCtrl.text.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Please enter a subject'),backgroundColor:Colors.redAccent));return;}
    if(_msgCtrl.text.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Please enter a message'),backgroundColor:Colors.redAccent));return;}
    setState(()=>_loading=true);
    try {
      final u=FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('feedbacks').add({'type':_type,'subject':_subCtrl.text.trim(),'message':_msgCtrl.text.trim(),'userId':u?.uid??'anonymous','userEmail':u?.email??'anonymous','status':'unread','createdAt':DateTime.now().toIso8601String()});
      setState((){_submitted=true;_loading=false;});
    } catch(e){setState(()=>_loading=false);if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Failed. Try again.'),backgroundColor:Colors.redAccent));}
  }

  void _reset(){_subCtrl.clear();_msgCtrl.clear();setState((){_submitted=false;_type='General';});}

  @override
  Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Feedback',style:TextStyle(color:AppColors.textPrimary,fontSize:16,fontWeight:FontWeight.w500))),
    body:_submitted?_success():_form());

  Widget _success()=>Center(child:Padding(padding:const EdgeInsets.all(32),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    Container(width:80,height:80,decoration:BoxDecoration(color:AppColors.onlineDark,borderRadius:BorderRadius.circular(24),border:Border.all(color:AppColors.online,width:.5)),child:const Icon(Icons.check_rounded,color:AppColors.online,size:40)),
    const SizedBox(height:24),
    const Text('Feedback sent!',style:TextStyle(color:AppColors.textPrimary,fontSize:22,fontWeight:FontWeight.w500)),
    const SizedBox(height:10),
    const Text('Thank you for helping us improve\nBags Agent Market.',style:TextStyle(color:AppColors.textSecondary,fontSize:14,height:1.6),textAlign:TextAlign.center),
    const SizedBox(height:32),
    ElevatedButton(onPressed:_reset,child:const Text('Send another feedback')),
  ])));

  Widget _form()=>SingleChildScrollView(padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:AppColors.accentDark,borderRadius:BorderRadius.circular(12),border:Border.all(color:AppColors.primary,width:.5)),
      child:const Row(children:[Icon(Icons.feedback_rounded,color:AppColors.accent,size:18),SizedBox(width:10),Expanded(child:Text('Your feedback helps us build a better platform.',style:TextStyle(color:AppColors.accentLight,fontSize:12,height:1.4)))])),
    const SizedBox(height:20),
    const Text('Type',style:TextStyle(color:AppColors.textSecondary,fontSize:12,fontWeight:FontWeight.w500)),
    const SizedBox(height:8),
    Wrap(spacing:8,runSpacing:8,children:_types.map((t){
      final s=t==_type;
      return GestureDetector(onTap:()=>setState(()=>_type=t),child:Container(padding:const EdgeInsets.symmetric(horizontal:14,vertical:8),
        decoration:BoxDecoration(color:s?AppColors.accentDark:AppColors.bgCard,borderRadius:BorderRadius.circular(20),border:Border.all(color:s?AppColors.primary:AppColors.bgCardBorder,width:.5)),
        child:Text(t,style:TextStyle(color:s?AppColors.accentLight:AppColors.textMuted,fontSize:12,fontWeight:FontWeight.w500))));
    }).toList()),
    const SizedBox(height:16),
    const Text('Subject',style:TextStyle(color:AppColors.textSecondary,fontSize:12,fontWeight:FontWeight.w500)),
    const SizedBox(height:6),
    TextField(controller:_subCtrl,style:const TextStyle(color:AppColors.textPrimary),decoration:const InputDecoration(hintText:'Brief summary',hintStyle:TextStyle(color:AppColors.textMuted))),
cat > lib/screens/main_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'feedback_screen.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key,required this.user});
  @override State<MainScreen> createState()=>_MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  int _i=0;
  late final List<Widget> _screens=[HomeScreen(user:widget.user),const ExploreScreen(),ProfileScreen(user:widget.user),const FeedbackScreen()];
  @override
  Widget build(BuildContext context)=>Scaffold(
    body:_screens[_i],
    bottomNavigationBar:Container(
      decoration:const BoxDecoration(color:Color(0xFF12121C),border:Border(top:BorderSide(color:AppColors.bgCardBorder,width:.5))),
      child:SafeArea(child:Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Row(children:[
        _Nav(icon:Icons.grid_view_rounded,label:'My agents',active:_i==0,onTap:()=>setState(()=>_i=0)),
        _Nav(icon:Icons.explore_rounded,label:'Explore',active:_i==1,onTap:()=>setState(()=>_i=1)),
        _Nav(icon:Icons.person_rounded,label:'Profile',active:_i==2,onTap:()=>setState(()=>_i=2)),
        _Nav(icon:Icons.feedback_rounded,label:'Feedback',active:_i==3,onTap:()=>setState(()=>_i=3)),
      ])))),
  );
}
class _Nav extends StatelessWidget {
  final IconData icon; final String label; final bool active; final VoidCallback onTap;
  const _Nav({required this.icon,required this.label,required this.active,required this.onTap});
  @override
  Widget build(BuildContext context)=>Expanded(child:GestureDetector(onTap:onTap,behavior:HitTestBehavior.opaque,child:Column(mainAxisSize:MainAxisSize.min,children:[
    Icon(icon,color:active?AppColors.accent:AppColors.textMuted,size:22),
    const SizedBox(height:4),
    Text(label,style:TextStyle(color:active?AppColors.accent:AppColors.textMuted,fontSize:10,fontWeight:FontWeight.w500)),
    if(active)...[const SizedBox(height:4),Container(width:4,height:4,decoration:const BoxDecoration(color:AppColors.accent,shape:BoxShape.circle))],
  ])));
}
