enum UserRole {
  resident('resident'),
  owner('owner'),
  messProvider('mess_provider'),
  admin('admin');

  const UserRole(this.value);

  /// String stored in Firestore `users/{uid}.role`
  final String value;

  static UserRole? fromValue(String? value) {
    if (value == 'student') return UserRole.resident; // legacy documents
    for (final role in UserRole.values) {
      if (role.value == value) return role;
    }
    return null;
  }
}
