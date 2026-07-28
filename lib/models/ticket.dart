class Ticket {
  final int? ticketId;
  final String title;
  final String description;
  final String priority;
  final String status;
  final int userId;
  final int? technicianId;
  final int departmentId;
  final String category;
  final String suggestedPriority;
  final String suggestedSolution;

  Ticket({
    this.ticketId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.userId,
    required this.technicianId,
    required this.departmentId,
    required this.category,
    required this.suggestedPriority,
    required this.suggestedSolution,
    
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json["ticketId"],
      title: json["title"],
      description: json["description"],
      priority: json["priority"],
      status: json["status"],
      userId: json["userId"],
      technicianId: json["technicianId"],
      departmentId: json["departmentId"],
      category: json["category"] ?? "",
      suggestedPriority: json["suggestedPriority"] ?? "",
      suggestedSolution: json["suggestedSolution"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
  return {
    "title": title,
    "description": description,
    "departmentId": departmentId,
    "userId": userId,
    "category": category,
    "suggestedPriority": suggestedPriority,
    "suggestedSolution": suggestedSolution,
  };
}
}