class LoginResponse {
  final int userId;
  final String fullName;
  final String email;
  final String role;
  final String department;

  LoginResponse({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.department,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userId: json["userId"],
      fullName: json["fullName"],
      email: json["email"],
      role: json["role"],
      department: json["department"],
    );
  }
}