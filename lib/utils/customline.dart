import 'package:flutter/material.dart';

class CustomLine extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size) {
   var paint = Paint()
   ..color = Colors.teal
   ..strokeWidth = 5
   ..strokeCap = StrokeCap.round;

   Offset startipoint = Offset(0, size.height/2);
   Offset endpoint = Offset(size.width, size.height/2);
   
   canvas.drawLine(startipoint, endpoint, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
  
}