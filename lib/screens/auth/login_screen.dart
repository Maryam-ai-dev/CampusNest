import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_footer_link.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/google_button.dart';
import '../../widgets/primary_button.dart';
import 'owner_login_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
      // AuthGate in app.dart switches to the home screen automatically.
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
      await AuthService.instance.signInWithGoogle();
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
                    const AuthHeader(
                      title: 'Welcome back',
                      subtitle: 'Log in to find your hostel & mess',
                    ),
                    const SizedBox(height: 36),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            label: 'University email',
                            hint: 'you@university.edu.pk',
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
                      prefix: 'New to CampusNest? ',
                      action: 'Sign up',
                      fontSize: 15,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      ),
                    ),
                    AuthFooterLink(
                      prefix: 'Listing a hostel or mess? ',
                      action: 'Continue as Owner →',
                      actionColor: AppColors.textDark,
                      fontSize: 14,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OwnerLoginScreen(),
                        ),
                      ),
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
