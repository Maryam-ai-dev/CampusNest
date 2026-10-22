import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/user_role.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/auth/complete_profile_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/student/student_shell.dart';
import 'services/auth_service.dart';

class CampusNestApp extends StatelessWidget {
  const CampusNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusNest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        textTheme: GoogleFonts.workSansTextTheme(),
      ),
      home: const SplashScreen(next: AuthGate()),
    );
  }
}

/// signed out -> Role selection
/// signed in, email not verified -> Verify email
/// verified, no profile (Google users) -> Pick a username / owner details
/// verified + profile -> Home for the saved role
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _Loading();
        }
        final user = AuthService.instance.currentUser;
        if (user == null) return const RoleSelectionScreen();
        if (!user.emailVerified) {
          return VerifyEmailScreen(onVerified: () => setState(() {}));
        }
        return _ProfileGate(key: ValueKey(user.uid), user: user);
      },
    );
  }
}

class _ProfileGate extends StatefulWidget {
  const _ProfileGate({super.key, required this.user});

  final User user;

  @override
  State<_ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<_ProfileGate> {
  late Future<String?> _future = AuthService.instance.getRole(widget.user.uid);

  void _recheck() {
    setState(() {
      _future = AuthService.instance.getRole(widget.user.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _Loading();
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load your profile.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _recheck,
                    child: const Text('Retry'),
                  ),
                  TextButton(
                    onPressed: AuthService.instance.signOut,
                    child: const Text('Log out'),
                  ),
                ],
              ),
            ),
          );
        }

        final raw = snapshot.data;
        // No profile document yet (new Google users).
        if (raw == null) return CompleteProfileScreen(onDone: _recheck);

        // Role comes only from Firestore. Legacy 'student' maps to resident.
        final role = UserRole.fromValue(raw);
        if (role == UserRole.admin) return const AdminDashboardScreen();
        if (role == UserRole.owner) {
          return const _HomePlaceholder(title: 'Owner dashboard coming soon');
        }
        if (role == UserRole.messProvider) {
          return const _HomePlaceholder(
            title: 'Mess provider dashboard coming soon',
          );
        }
        return const StudentShell(); // resident (and any unknown value)
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

/// Temporary home for owners and mess providers until their dashboards exist.
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$title\n${user?.displayName ?? user?.email ?? ''}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: AuthService.instance.signOut,
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
