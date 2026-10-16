import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_footer_link.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/google_button.dart';
import '../../widgets/owner_auth_header.dart';
import '../../widgets/primary_button.dart';
import 'owner_signup_screen.dart';

class OwnerLoginScreen extends StatefulWidget {
  const OwnerLoginScreen({super.key});

  @override
  State<OwnerLoginScreen> createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends State<OwnerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;

  bool get _busy => _isLoading || _isGoogleLoading;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _logIn() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      await AuthService.instance.signInWithEmail(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      // Back to the AuthGate, which shows verify / home.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    FocusScope.of(context).unfocus();
    setState(() => _isGoogleLoading = true);
    try {
      final result = await AuthService.instance.signInWithGoogle(role: 'owner');
      if (!mounted) return;
      if (result != null) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    const OwnerAuthHeader(
                      title: 'Owner Log In',
                      subtitle: 'Log in to manage your hostel listings',
                    ),
                    const SizedBox(height: 36),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            label: 'Email',
                            hint: 'owner@example.com',
                            controller: _emailCtrl,
                            validator: Validators.email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            enabled: !_busy,
                          ),
                          const SizedBox(height: 18),
                          CustomTextField(
                            label: 'Password',
                            hint: '••••••••',
                            controller: _passwordCtrl,
                            validator: Validators.requiredPassword,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            enabled: !_busy,
                            onSubmitted: _logIn,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Log In',
                      isLoading: _isLoading,
                      onPressed: _busy ? null : _logIn,
                    ),
                    const SizedBox(height: 20),
                    const OrDivider(),
                    const SizedBox(height: 20),
                    GoogleButton(
                      isLoading: _isGoogleLoading,
                      onPressed: _busy ? null : _googleSignIn,
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),
                    AuthFooterLink(
                      prefix: 'New owner? ',
                      action: 'Sign up',
                      fontSize: 15,
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const OwnerSignupScreen(),
                        ),
                      ),
                    ),
                    AuthFooterLink(
                      prefix: 'Looking for a hostel instead? ',
                      action: 'Continue as Student →',
                      actionColor: AppColors.textDark,
                      fontSize: 14,
                      onTap: () => Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst),
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
