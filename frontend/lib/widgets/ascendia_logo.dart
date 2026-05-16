import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class AscendiaLogo extends StatelessWidget {
  final double size;
  const AscendiaLogo({super.key, this.size = 1.0});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(150 * size, 100 * size),
          painter: _LogoPainter(),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Ascend',
                style: GoogleFonts.inter(
                  fontSize: 28 * size,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'IA',
                style: GoogleFonts.inter(
                  fontSize: 28 * size,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        Text(
          'CLIMB SMARTER',
          style: GoogleFonts.inter(
            fontSize: 10 * size,
            letterSpacing: 3,
            color: AppColors.primaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final axisPaint = Paint()
      ..color = const Color(0xFFC5D8EB)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0.07 * w, 0.88 * h), Offset(0.93 * w, 0.88 * h), axisPaint);

    final dashPaint = Paint()
      ..color = const Color(0xFFB8D4E8)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    void drawDash(double x, double y1, double y2) {
      const dashLen = 3.0;
      const gap = 3.0;
      double y = y1;
      while (y > y2) {
        canvas.drawLine(Offset(x, y), Offset(x, (y - dashLen).clamp(y2, y1)), dashPaint);
        y -= dashLen + gap;
      }
    }

    drawDash(0.17 * w, 0.88 * h, 0.76 * h);
    drawDash(0.37 * w, 0.88 * h, 0.58 * h);
    drawDash(0.60 * w, 0.88 * h, 0.40 * h);
    drawDash(0.80 * w, 0.88 * h, 0.22 * h);

    final curvePaint = Paint()
      ..color = const Color(0xFF42A5F5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0.08 * w, 0.82 * h)
      ..cubicTo(0.11 * w, 0.80 * h, 0.14 * w, 0.78 * h, 0.17 * w, 0.76 * h)
      ..cubicTo(0.25 * w, 0.70 * h, 0.31 * w, 0.62 * h, 0.37 * w, 0.58 * h)
      ..cubicTo(0.45 * w, 0.52 * h, 0.52 * w, 0.46 * h, 0.60 * w, 0.40 * h)
      ..cubicTo(0.68 * w, 0.34 * h, 0.73 * w, 0.26 * h, 0.80 * w, 0.22 * h);
    canvas.drawPath(path, curvePaint);

    final dots = [
      (0.08 * w, 0.82 * h, 4.0, const Color(0xFFBDBDBD)),
      (0.17 * w, 0.76 * h, 4.5, const Color(0xFF90CAF9)),
      (0.37 * w, 0.58 * h, 5.0, const Color(0xFF42A5F5)),
      (0.60 * w, 0.40 * h, 5.5, const Color(0xFF1E88E5)),
      (0.80 * w, 0.22 * h, 7.5, AppColors.primaryDark),
    ];

    for (final (x, y, r, color) in dots) {
      canvas.drawCircle(Offset(x, y), r, Paint()..color = color);
    }
    canvas.drawCircle(
      Offset(0.80 * w, 0.22 * h),
      3.5,
      Paint()..color = const Color(0x9990CAF9),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
