/// Matches the raw shape returned by GET /api/Users (the Users entity),
/// used only for the manager's "Manage Users" / password-reset screen.
class AppUser {
  final int userId;
  final String fullName;
  final String email;
  final int roleId;

  AppUser({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.roleId,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      userId: json["userId"],
      fullName: json["fullName"] ?? "",
      email: json["email"] ?? "",
      // Adjust the key name below if your backend serializes it differently
      // (e.g. "roleId" vs "RoleId" — check a live GET /api/Users response).
      roleId: json["roleId"] ?? 0,
    );
  }

  String get roleName {
    switch (roleId) {
      case 1:
        return "Employee";
      case 2:
        return "Technician";
      case 3:
        return "Manager";
      default:
        return "Unknown";
    }
  }
}