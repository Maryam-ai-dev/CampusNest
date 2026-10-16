import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_footer_link.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/primary_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.onVerified});

  final VoidCallback onVerified;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _pollTimer;
  Timer? _cooldownTimer;
  int _cooldown = 0;
  bool _inFlight = false;
  bool _checkingUi = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    // Auto-detect verification every few seconds.
    _pollTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _check(silent: true),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? AppColors.error : null,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _check({bool silent = false}) async {
    if (_inFlight) return;
    _inFlight = true;
    if (!silent) setState(() => _checkingUi = true);
    try {
      final verified = await AuthService.instance.reloadAndCheckVerified();
      if (!mounted) return;
      if (verified) {
        widget.onVerified();
      } else if (!silent) {
        _snack('Not verified yet. Check your inbox and spam folder.');
      }
    } on AuthException catch (e) {
      if (!silent && mounted) _snack(e.message, error: true);
    } finally {
      _inFlight = false;
      if (!silent && mounted) setState(() => _checkingUi = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await AuthService.instance.sendVerificationEmail();
      if (!mounted) return;
      _snack('Verification email sent.');
      _startCooldown();
    } on AuthException catch (e) {
      if (mounted) _snack(e.message, error: true);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _startCooldown() {
    setState(() => _cooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _cooldown--);
      if (_cooldown <= 0) t.cancel();
    });
  }

  Future<void> _startOver() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start over?'),
        content: const Text(
          'This deletes the unverified account and frees your username, '
          'so you can sign up again with the correct email.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await AuthService.instance.deleteCurrentAccount();
    } on AuthException catch (e) {
      if (mounted) _snack(e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = AuthService.instance.currentUser?.email ?? '';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    AuthHeader(
                      title: 'Verify your email',
                      subtitle: 'We sent a verification link to\n$email',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Open the link in that email, then come back here. '
                      'It can take a minute to arrive, so check your spam folder too.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.workSans(
                        fontSize: 13.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: "I've verified my email",
                      isLoading: _checkingUi,
                      onPressed: _check,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: (_cooldown > 0 || _resending)
                            ? null
                            : _resend,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          _cooldown > 0
                              ? 'Resend email in ${_cooldown}s'
                              : 'Resend email',
                          style: GoogleFonts.workSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),
                    AuthFooterLink(
                      prefix: 'Wrong email? ',
                      action: 'Start over',
                      onTap: _startOver,
                    ),
                    AuthFooterLink(
                      prefix: 'Verify later? ',
                      action: 'Log out',
                      actionColor: AppColors.textDark,
                      onTap: AuthService.instance.signOut,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
