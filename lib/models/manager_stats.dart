class ManagerStats {
  final int open;
  final int inProgress;
  final int resolved;
  final int closed;

  ManagerStats({
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.closed,
  });

  factory ManagerStats.fromJson(Map<String, dynamic> json) {
    return ManagerStats(
      open: json["open"],
      inProgress: json["inProgress"],
      resolved: json["resolved"],
      closed: json["closed"],
    );
  }
}