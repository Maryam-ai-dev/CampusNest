import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/user_role.dart';
import '../../core/utils/role_navigation.dart';
import '../../widgets/role_card.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _open(BuildContext context, UserRole role) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RoleNavigation.authScreenFor(role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 56),
                      const _Logo(),
                      const SizedBox(height: 28),
                      Text(
                        'Welcome to CampusNest',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fraunces(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'How would you like to continue?',
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          color: AppColors.hint,
                        ),
                      ),
                      const SizedBox(height: 32),
                      RoleCard(
                        icon: Icons.person_outline,
                        iconBg: const Color(0xFFFFF0EA),
                        iconColor: AppColors.primary,
                        title: 'Resident',
                        subtitle: 'Find a hostel and mess near your campus',
                        onTap: () => _open(context, UserRole.resident),
                      ),
                      const SizedBox(height: 14),
                      RoleCard(
                        icon: Icons.apartment_outlined,
                        iconBg: const Color(0xFFEDE7DB),
                        iconColor: AppColors.textDark,
                        title: 'Hostel Owner',
                        subtitle: 'List your hostel and reach residents',
                        onTap: () => _open(context, UserRole.owner),
                      ),
                      const SizedBox(height: 14),
                      RoleCard(
                        icon: Icons.restaurant_outlined,
                        iconBg: const Color(0xFFE3EBE3),
                        iconColor: const Color(0xFF2F4A3A),
                        title: 'Mess Provider',
                        subtitle: 'List your mess or tiffin service',
                        onTap: () => _open(context, UserRole.messProvider),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 12),
                child: OutlinedButton.icon(
                  onPressed: () => _open(context, UserRole.admin),
                  icon: const Icon(
                    Icons.lock_outline,
                    size: 15,
                    color: AppColors.hint,
                  ),
                  label: Text(
                    'Admin login',
                    style: GoogleFonts.workSans(
                      fontSize: 13,
                      color: AppColors.hint,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD9744A), AppColors.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.home_outlined, color: Colors.white, size: 26),
    );
  }
}
