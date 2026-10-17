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
<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';
import '../student/student_shell.dart';
import '../admin/admin_dashboard_screen.dart';
=======
>>>>>>> b0070f17671e62dad7f87406ba2e23427541efcf

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

<<<<<<< HEAD
  // Single unified login function with admin routing
  Future<void> _logIn([String? value]) async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      // 1. Sign in with Firebase Authentication
      final credential = await AuthService.instance.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (!mounted) return;

      final email = _emailCtrl.text.trim();

      // 2. Check for your specific admin email
      if (email == 'admincampustnest@gmail.com') {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(credential.user!.uid)
              .set({'role': 'admin'}, SetOptions(merge: true));
        } catch (_) {
          // Ignore if Firestore setup restricts this
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
        return;
      }

      // 3. Check role from Firestore for other users
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        final role = userDoc.data()?['role'];

        if (!mounted) return;

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
          return;
        }
      } catch (_) {
        // Fallback if Firestore read fails
      }

      if (!mounted) return;
      // Default redirection for students
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StudentShell()),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Login failed: $e');
=======
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
>>>>>>> b0070f17671e62dad7f87406ba2e23427541efcf
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
<<<<<<< HEAD
                          // --- Forgot Email Button ---
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
                                String input = '';
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Find Email'),
                                      content: TextField(
                                        onChanged: (value) => input = value,
                                        decoration: const InputDecoration(
                                          hintText: 'Enter Username or Phone',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            if (input.trim().isEmpty) return;
                                            Navigator.pop(context);
                                            try {
                                              String? foundEmail = await AuthService.instance.findEmailByUsernameOrPhone(
                                                input.trim(),
                                              );
                                              if (!context.mounted) return;
                                              if (foundEmail != null) {
                                                _emailCtrl.text = foundEmail;
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Email found: $foundEmail (Set in the email field)'),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('No email found with this username or phone number.'),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Error: $e')),
                                              );
                                            }
                                          },
                                          child: const Text('Find'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: const Text(
                                'Forgot Email?',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
=======
>>>>>>> b0070f17671e62dad7f87406ba2e23427541efcf
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
<<<<<<< HEAD
                          // --- Forgot Password Button ---
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
                                if (_emailCtrl.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter your email address above first, then tap Forgot Password.'),
                                    ),
                                  );
                                  return;
                                }
                                try {
                                  await AuthService.instance.sendPasswordResetEmail(
                                    email: _emailCtrl.text.trim(),
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Password reset email sent! Check your inbox.'),
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
=======
>>>>>>> b0070f17671e62dad7f87406ba2e23427541efcf
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
<<<<<<< HEAD
}
=======
}
>>>>>>> b0070f17671e62dad7f87406ba2e23427541efcf
