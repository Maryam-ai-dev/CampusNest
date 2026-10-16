import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/primary_button.dart';
import 'hostel_search_screen.dart';

/// Student app frame: bottom navigation with Search / Mess / Bookings / Profile.
class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  static const _items = [
    _NavItem('Search', Icons.search),
    _NavItem('Mess', Icons.restaurant_outlined),
    _NavItem('Bookings', Icons.assignment_outlined),
    _NavItem('Profile', Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _index,
        children: const [
          HostelSearchScreen(),
          _ComingSoonTab(title: 'Mess & tiffin services'),
          _ComingSoonTab(title: 'Your bookings'),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < _items.length; i++)
                  Expanded(
                    child: _NavButton(
                      item: _items[i],
                      selected: i == _index,
                      onTap: () => setState(() => _index = i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.hint;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: GoogleFonts.workSans(
              fontSize: 11.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Temporary tab until its real screen is built.
class _ComingSoonTab extends StatelessWidget {
  const _ComingSoonTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.fraunces(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coming soon',
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Temporary profile tab: shows who is signed in and lets you log out.
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user?.displayName ?? 'Student',
              style: GoogleFonts.fraunces(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: GoogleFonts.workSans(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Log out',
              onPressed: AuthService.instance.signOut,
            ),
          ],
        ),
      ),
    );
  }
}