import 'package:flutter/material.dart';

class EvoFlixLogo extends StatelessWidget {
  final double size;
  final bool showGlow;

  const EvoFlixLogo({
    super.key,
    this.size = 120,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showGlow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D9FF).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: const Color(0xFFFF1493).withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            )
          : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.25),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00D9FF), // Cyan
              Color(0xFF4169E1), // Blue
              Color(0xFFFF1493), // Pink
            ],
          ),
        ),
        child: Container(
          margin: EdgeInsets.all(size * 0.02),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.23),
            color: const Color(0xFF0A1628),
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Play button triangle
                CustomPaint(
                  size: Size(size * 0.5, size * 0.5),
                  painter: _PlayButtonPainter(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayButtonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF00FFFF), // Cyan
          Color(0xFF8A2BE2), // Purple
          Color(0xFFFF1493), // Pink
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Play triangle
    path.moveTo(size.width * 0.25, size.height * 0.15);
    path.lineTo(size.width * 0.25, size.height * 0.85);
    path.lineTo(size.width * 0.85, size.height * 0.5);
    path.close();

    canvas.drawPath(path, paint);

    // Accent line under play button
    final linePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF00FFFF),
          Color(0xFFFF1493),
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.9, size.width, 8))
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.95),
      Offset(size.width * 0.9, size.height * 0.95),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
