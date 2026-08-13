class Ticket {
  final int? ticketId;
  final String title;
  final String description;
  final String priority;
  final String status;
  final String createdAt;
  final int userId;
  final int? technicianId;
  final int departmentId;
  final String departmentName;
  
  final String category;
  final String suggestedPriority;
  final String suggestedSolution;
  final String? technicianNotes;
  
  Ticket({
    this.ticketId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.userId,
    required this.technicianId,
    required this.departmentId,
    required this.departmentName,
    required this.category,
    required this.suggestedPriority,
    required this.suggestedSolution,
    this.technicianNotes,
    
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json["ticketId"],
      title: json["title"],
      description: json["description"],
      priority: json["priority"],
      status: json["status"],
      createdAt: json["createdAt"] ?? "",
      userId: json["userId"],
      technicianId: json["technicianId"],
      departmentId: json["departmentId"],
      departmentName: json["departmentName"] ?? "",
      category: json["category"] ?? "",
      suggestedPriority: json["suggestedPriority"] ?? "",
      suggestedSolution: json["suggestedSolution"] ?? "",
      technicianNotes: json["technicianNotes"],
      
    );
  }

  Map<String, dynamic> toJson() {
  return {
    "title": title,
    "description": description,
    "departmentId": departmentId,
    "departmentName": departmentName,
    "userId": userId,
    "category": category,
    "suggestedPriority": suggestedPriority,
    "suggestedSolution": suggestedSolution,
  };
}
}