import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';
import '../models/department.dart';
import '../models/technician_stats.dart';
import '../models/login_response.dart';
import '../models/technician.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  static const String baseUrl = "http://localhost:5262/api";

  static const String departmentUrl =
      "http://localhost:5262/api/Departments";



 Future<List<Ticket>> getTickets() async {
  final response = await http.get(Uri.parse("$baseUrl/Tickets"));

  print("Status: ${response.statusCode}");
  print("Body: ${response.body}");

  if (response.statusCode == 200) {
    List data = jsonDecode(response.body);

    print("API returned ${data.length} tickets");

    for (var t in data) {
      print("TicketId: ${t["ticketId"]}");
      print("Status: ${t["status"]}");
    }

    return data.map((e) => Ticket.fromJson(e)).toList();
  } else {
    throw Exception("Failed to load tickets");
  }
}


  Future<bool> createTicket(Ticket ticket) async {
  final prefs = await SharedPreferences.getInstance();

  final userId = prefs.getInt("userId");

  if (userId == null) {
    print("ERROR: No logged-in user ID found");
    return false;
  }

  final ticketData = ticket.toJson();

  // Always use the currently logged-in user
  ticketData["userId"] = userId;

  print("Creating ticket with UserId: $userId");
  print("Sending: $ticketData");

  final response = await http.post(
    Uri.parse("$baseUrl/Tickets"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode(ticketData),
  );

  print("Create ticket status: ${response.statusCode}");
  print("Create ticket response: ${response.body}");

  return response.statusCode == 200 ||
      response.statusCode == 201;
}

  Future<List<Ticket>> getMyTickets() async {
  final prefs = await SharedPreferences.getInstance();

  final userId = prefs.getInt("userId");

  if (userId == null) {
    throw Exception("No logged-in user found");
  }

  print("Getting tickets for UserId: $userId");

  final response = await http.get(
    Uri.parse("$baseUrl/Tickets/my-tickets/$userId"),
  );

  print("My tickets status: ${response.statusCode}");
  print("My tickets body: ${response.body}");

  if (response.statusCode == 200) {
    List data = jsonDecode(response.body);

    print("API returned ${data.length} my tickets");

    for (var t in data) {
      print(
        "TicketId: ${t["ticketId"]} | UserId: ${t["userId"]}",
      );
    }

    return data.map((e) => Ticket.fromJson(e)).toList();
  } else {
    throw Exception("Failed to load my tickets");
  }
}

  Future<List<Department>> getDepartments() async {

    final response = await http.get(
      Uri.parse(departmentUrl),
    );

    if (response.statusCode == 200) {

      List data = jsonDecode(response.body);

      return data
          .map((e) => Department.fromJson(e))
          .toList();

    } else {

      throw Exception("Failed to load departments");

    }
  }
  Future<bool> updateTicket(int id, Ticket ticket) async {

  final response = await http.put(
    Uri.parse("$baseUrl/$id"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode(ticket.toJson()),
  );

  return response.statusCode == 204;
}
Future<bool> deleteTicket(int id) async {
  final prefs = await SharedPreferences.getInstance();

  final userId = prefs.getInt("userId");

  if (userId == null) {
    print("ERROR: No logged-in user found");
    return false;
  }

  print("Deleting ticket $id for UserId $userId");

  final response = await http.delete(
    Uri.parse("$baseUrl/Tickets/$id/$userId"),
  );

  print("Delete status: ${response.statusCode}");

  return response.statusCode == 204;
}
Future<bool> technicianUpdateTicket(
  int id,
  String priority,
  String status,
  int technicianId,
  String technicianNotes,
) async {
  final response = await http.put(
    Uri.parse("$baseUrl/Tickets/$id/technician"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "priority": priority,
      "status": status,
      "technicianId": technicianId,
      "technicianNotes": technicianNotes,
    }),
  );

  return response.statusCode == 204;
}
Future<List<Ticket>> getTechnicianTickets({
  int? technicianId,
  String? status,
}) async {
  String url = "$baseUrl/Tickets/technician";

  final params = <String, String>{};

  if (technicianId != null) {
    params["technicianId"] = technicianId.toString();
  }

  if (status != null && status != "All") {
    params["status"] = status;
  }

  if (params.isNotEmpty) {
    url += "?${Uri(queryParameters: params).query}";
  }

  print("GET => $url");

  final response = await http.get(
    Uri.parse(url),
  );

  print("Status: ${response.statusCode}");
  print("Body: ${response.body}");

  if (response.statusCode == 200) {
    List data = jsonDecode(response.body);

    print("API returned ${data.length} technician tickets");

    return data.map((e) => Ticket.fromJson(e)).toList();
  } else {
    throw Exception("Failed to load technician tickets");
  }
}
Future<TechnicianStats> getTechnicianStats(int technicianId) async {
  final url =
      "$baseUrl/Tickets/technician/stats?technicianId=$technicianId";

  print("GET => $url");

  final response = await http.get(Uri.parse(url));

  print("Status: ${response.statusCode}");
  print("Body: ${response.body}");

  if (response.statusCode == 200) {
    return TechnicianStats.fromJson(
      jsonDecode(response.body),
    );
  }

  throw Exception("Failed to load technician statistics");
}
Future<LoginResponse?> login(
    String email,
    String password,
) async {
  final response = await http.post(
    Uri.parse("$baseUrl/Auth/login"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "email": email,
      "passwordHash": password,
    }),
  );

  if (response.statusCode == 200) {
    return LoginResponse.fromJson(
      jsonDecode(response.body),
    );
  }

  return null;
}
Future<List<Technician>> getTechnicians() async {
  final url = "$baseUrl/Users/technicians";

  print("GET => $url");

  final response = await http.get(
    Uri.parse(url),
  );

  print("Status: ${response.statusCode}");
  print("Body: ${response.body}");

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);

    return data
        .map((json) => Technician.fromJson(json))
        .toList();
  }

  throw Exception("Failed to load technicians");
}
}