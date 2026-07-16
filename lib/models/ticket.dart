class Ticket {
  final int? ticketId;
  final String title;
  final String description;
  final String priority;
  final String status;
  final int userId;
  final int technicianId;

  Ticket({
    this.ticketId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.userId,
    required this.technicianId,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "priority": priority,
      "status": status,
      "userId": userId,
      "technicianId": technicianId,
    };
  }
}