import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.autofillHints,
    this.enabled = true,
    this.onSubmitted,
    this.inputFormatters,
    this.prefixText,
    this.autovalidateMode,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  /// When true, the field hides its text and shows an eye button to reveal it.
  final bool obscureText;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final VoidCallback? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final AutovalidateMode? autovalidateMode;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _hidden = widget.obscureText;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: AppColors.label,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          autovalidateMode: widget.autovalidateMode,
          keyboardType: widget.keyboardType,
          obscureText: _hidden,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          enabled: widget.enabled,
          onFieldSubmitted: (_) => widget.onSubmitted?.call(),
          style: GoogleFonts.workSans(fontSize: 15, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.workSans(
              fontSize: 15,
              color: AppColors.hint,
            ),
            prefixText: widget.prefixText,
            prefixStyle: GoogleFonts.workSans(
              fontSize: 15,
              color: AppColors.textMuted,
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    tooltip: _hidden ? 'Show password' : 'Hide password',
                    icon: Icon(
                      _hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.hint,
                    ),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            disabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.primary),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error),
            errorStyle: GoogleFonts.workSans(
              fontSize: 12,
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}
