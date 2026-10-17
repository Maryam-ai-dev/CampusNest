import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_colors.dart';
import 'screens/auth/complete_profile_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/student/student_shell.dart';
import 'services/auth_service.dart';
import 'screens/admin/admin_dashboard_screen.dart';

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

/// signed out -> Login
/// signed in, email not verified -> Verify email
/// verified, no profile (Google users) -> Pick a username / owner details
/// verified + profile -> Home
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
        if (user == null) return const LoginScreen();
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
    // 1. Direct check for your specific admin email at the root level
    if (widget.user.email == 'admincampustnest@gmail.com') {
      return const AdminDashboardScreen();
    }

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
        final role = snapshot.data;
        // 2. Fallback check for admin role from database
        if (role == 'admin') return const AdminDashboardScreen();
        if (role == null) return CompleteProfileScreen(onDone: _recheck);
        if (role == 'owner') return const _OwnerHomePlaceholder();
        return const StudentShell();
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

/// Temporary owner screen until the owner dashboard is built.
class _OwnerHomePlaceholder extends StatelessWidget {
  const _OwnerHomePlaceholder();

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Owner dashboard coming soon\n${user?.displayName ?? user?.email ?? ''}',
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
