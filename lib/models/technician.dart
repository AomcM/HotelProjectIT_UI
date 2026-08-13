class Technician {
  final int userId;
  final String fullName;

  Technician({
    required this.userId,
    required this.fullName,
  });

  factory Technician.fromJson(Map<String, dynamic> json) {
    return Technician(
      userId: json["userId"],
      fullName: json["fullName"],
    );
  }
}