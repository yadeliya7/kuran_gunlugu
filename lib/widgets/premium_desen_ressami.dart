import 'package:flutter/material.dart';

class PremiumDesenRessami extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
          .withValues(alpha: 0.03) // Çok çok silik beyaz (%3)
      ..strokeWidth = 1; // İncecik

    double step = 30.0; // Çizgilerin ne kadar sık olacağı (30px aralık)

    // Ekranı baştan aşağı çapraz tarıyoruz
    for (double i = -size.height; i < size.width; i += step) {
      // Çizgiyi çek: (x1, y1) -> (x2, y2)
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
