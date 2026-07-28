class Department {
  final int departmentId;
  final String departmentName;

  Department({
    required this.departmentId,
    required this.departmentName,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      departmentId: json["departmentId"],
      departmentName: json["departmentName"],
    );
  }
}