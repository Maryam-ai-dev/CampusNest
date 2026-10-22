import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

// After sign in, AuthGate sends the user to AdminDashboardScreen only if
// users/{uid}.role == 'admin'. Admin accounts are created by hand in the
// Firebase console.
class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(
          'Admin login',
          style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: Text(
          'Admin login\nComing soon',
          textAlign: TextAlign.center,
          style: GoogleFonts.workSans(fontSize: 15, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
