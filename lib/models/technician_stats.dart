class TechnicianStats {
  final int open;
  final int inProgress;
  final int closed;

  TechnicianStats({
    required this.open,
    required this.inProgress,
    required this.closed,
  });

  factory TechnicianStats.fromJson(Map<String, dynamic> json) {
    return TechnicianStats(
      open: json["open"],
      inProgress: json["inProgress"],
      closed: json["closed"],
    );
  }
}