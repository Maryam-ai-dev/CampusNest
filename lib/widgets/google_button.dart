import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR CONTINUE WITH',
            style: GoogleFonts.workSans(
              fontSize: 12,
              letterSpacing: 0.8,
              color: AppColors.hint,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }
}

class GoogleButton extends StatelessWidget {
  const GoogleButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CustomPaint(painter: _GoogleLogoPainter()),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: GoogleFonts.workSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Simple drawn "G" so no image asset is needed.
class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  double _rad(double deg) => deg * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.22;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    Paint paint(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    canvas.drawArc(
      rect,
      _rad(225),
      _rad(90),
      false,
      paint(const Color(0xFFEA4335)),
    );
    canvas.drawArc(
      rect,
      _rad(135),
      _rad(90),
      false,
      paint(const Color(0xFFFBBC05)),
    );
    canvas.drawArc(
      rect,
      _rad(45),
      _rad(90),
      false,
      paint(const Color(0xFF34A853)),
    );
    canvas.drawArc(
      rect,
      _rad(-2),
      _rad(47),
      false,
      paint(const Color(0xFF4285F4)),
    );

    final center = size.center(Offset.zero);
    canvas.drawRect(
      Rect.fromLTRB(
        center.dx,
        center.dy - stroke / 2,
        size.width,
        center.dy + stroke / 2,
      ),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
