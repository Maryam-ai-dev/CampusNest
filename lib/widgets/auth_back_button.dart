import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Round back button for the top-left of auth screens.
/// Hidden automatically if there is nothing to go back to.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Navigator.of(context).canPop()) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.of(context).maybePop(),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
