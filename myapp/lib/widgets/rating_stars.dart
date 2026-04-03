import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
class RatingStars extends StatelessWidget {
  final double rating; final double size;
  const RatingStars({super.key,required this.rating,this.size=16});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize:MainAxisSize.min,children:List.generate(5,(i)=>Icon(i<rating.floor()?Icons.star_rounded:i<rating?Icons.star_half_rounded:Icons.star_outline_rounded,color:const Color(0xFFFAC775),size:size)));
}
class InteractiveRatingStars extends StatefulWidget {
  final double initialRating; final ValueChanged<double> onRatingChanged;
  const InteractiveRatingStars({super.key,this.initialRating=0,required this.onRatingChanged});
  @override State<InteractiveRatingStars> createState()=>_State();
}
class _State extends State<InteractiveRatingStars> {
  late double _r;
  @override void initState(){super.initState();_r=widget.initialRating;}
  @override
  Widget build(BuildContext context)=>Row(mainAxisSize:MainAxisSize.min,children:List.generate(5,(i)=>GestureDetector(onTap:(){setState(()=>_r=i+1.0);widget.onRatingChanged(_r);},child:Padding(padding:const EdgeInsets.symmetric(horizontal:2),child:Icon(i<_r?Icons.star_rounded:Icons.star_outline_rounded,color:i<_r?const Color(0xFFFAC775):AppColors.textMuted,size:32)))));
}
