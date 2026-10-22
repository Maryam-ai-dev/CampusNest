import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/user_role.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_footer_link.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/mess_auth_header.dart';
import '../../widgets/owner_auth_header.dart';
import '../../widgets/primary_button.dart';

/// Shown once to Google users who don't have a profile yet.
/// Residents pick a username; owners and mess providers enter business
/// name and phone.
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _businessCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;

  String get _role => AuthService.instance.pendingRole;
  bool get _isMess => _role == UserRole.messProvider.value;

  /// Owners and mess providers share the same form (business name + phone).
  bool get _isBusiness => _role == UserRole.owner.value || _isMess;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _businessCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      if (_isBusiness) {
        if (_isMess) {
          await AuthService.instance.completeMessProviderProfile(
            businessName: _businessCtrl.text,
            phone: _phoneCtrl.text,
          );
        } else {
          await AuthService.instance.completeOwnerProfile(
            businessName: _businessCtrl.text,
            phone: _phoneCtrl.text,
          );
        }
      } else {
        await AuthService.instance.completeProfile(
          username: _usernameCtrl.text,
        );
      }
      if (mounted) widget.onDone();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final business = _isBusiness;
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
                    if (_isMess)
                      const MessAuthHeader(
                        title: 'Almost there',
                        subtitle: 'Add your details to start listing your mess',
                      )
                    else if (business)
                      const OwnerAuthHeader(
                        title: 'Almost there',
                        subtitle: 'Add your details to start listing',
                      )
                    else
                      const AuthHeader(
                        title: 'Pick a username',
                        subtitle: 'This is how other residents will see you',
                      ),
                    const SizedBox(height: 36),
                    Form(
                      key: _formKey,
                      child: business
                          ? Column(
                              children: [
                                CustomTextField(
                                  label: _isMess
                                      ? 'Mess / business name'
                                      : 'Owner / business name',
                                  hint: _isMess
                                      ? 'Al-Noor Mess'
                                      : 'Al-Noor Boys Hostel',
                                  controller: _businessCtrl,
                                  validator: Validators.businessName,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  enabled: !_isLoading,
                                ),
                                const SizedBox(height: 18),
                                CustomTextField(
                                  label: 'Phone number',
                                  hint: '03XX XXXXXXX',
                                  controller: _phoneCtrl,
                                  validator: Validators.phone,
                                  inputFormatters: Validators.phoneFormatters,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.done,
                                  enabled: !_isLoading,
                                  onSubmitted: _submit,
                                ),
                              ],
                            )
                          : CustomTextField(
                              label: 'Username',
                              hint: 'ayesha.khan',
                              prefixText: '@',
                              controller: _usernameCtrl,
                              validator: Validators.username,
                              inputFormatters: Validators.usernameFormatters,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                              enabled: !_isLoading,
                              onSubmitted: _submit,
                            ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Continue',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                    const Spacer(),
                    AuthFooterLink(
                      prefix: 'Not you? ',
                      action: 'Log out',
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
