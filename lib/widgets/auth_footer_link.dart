import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prefix,
    required this.action,
    required this.onTap,
    this.actionColor = AppColors.primary,
    this.fontSize = 14,
  });

  final String prefix;
  final String action;
  final VoidCallback onTap;
  final Color actionColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          prefix,
          style: GoogleFonts.workSans(
            fontSize: fontSize,
            color: AppColors.textMuted,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              action,
              style: GoogleFonts.workSans(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: actionColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
