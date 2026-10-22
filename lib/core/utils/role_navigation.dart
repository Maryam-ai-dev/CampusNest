import 'package:flutter/widgets.dart';

import '../../screens/auth/admin_login_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/mess_provider_login_screen.dart';
import '../../screens/auth/owner_login_screen.dart';
import '../constants/user_role.dart';

class RoleNavigation {
  RoleNavigation._();

  /// Screen opened from RoleSelectionScreen for the chosen role.
  static Widget authScreenFor(UserRole role) {
    switch (role) {
      case UserRole.resident:
        return LoginScreen(role: role);
      case UserRole.owner:
        return OwnerLoginScreen(role: role);
      case UserRole.messProvider:
        return MessProviderLoginScreen(role: role);
      case UserRole.admin:
        return const AdminLoginScreen();
    }
  }
}
