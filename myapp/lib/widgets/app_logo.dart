import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 36});
  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size, child: CustomPaint(painter: _LogoPainter()));
}
class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width/2; final cy = size.height/2; final r = size.width*0.42;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx,cy), radius: r), 0.5, 4.5, false, Paint()..color=AppColors.primary..style=PaintingStyle.stroke..strokeWidth=size.width*0.07..strokeCap=StrokeCap.round);
    canvas.drawPath(Path()..moveTo(size.width*0.58,size.height*0.15)..lineTo(size.width*0.85,size.height*0.15)..lineTo(size.width*0.6,size.height*0.42), Paint()..color=AppColors.accent..style=PaintingStyle.stroke..strokeWidth=size.width*0.08..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round);
    canvas.drawCircle(Offset(cx,cy), size.width*0.13, Paint()..color=AppColors.accentLight);
    canvas.drawCircle(Offset(cx,cy), size.width*0.06, Paint()..color=AppColors.primary);
  }
  @override bool shouldRepaint(_) => false;
}
class AppLogoWithText extends StatelessWidget {
  const AppLogoWithText({super.key});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    const AppLogo(size: 32), const SizedBox(width: 10),
    Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      RichText(text: const TextSpan(style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary, letterSpacing: .04), children: [TextSpan(text: '▲', style: TextStyle(color: AppColors.accent, fontSize: 12)), TextSpan(text: 'BAGS')])),
      const Text('AGENT MARKET', style: TextStyle(fontSize: 8, letterSpacing: .12, color: AppColors.primary, fontWeight: FontWeight.w500)),
    ]),
  ]);
}
