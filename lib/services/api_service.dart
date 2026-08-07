import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';
import '../models/department.dart';
import '../models/technician_stats.dart';
import '../models/login_response.dart';

class ApiService {

  static const String baseUrl = "http://10.0.2.2:5262/api";

  static const String departmentUrl =
      "http://10.0.2.2:5262/api/Departments";

      

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

    final response = await http.post(
      Uri.parse("$baseUrl/Tickets"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(ticket.toJson()),
    );

    return response.statusCode == 200 ||
        response.statusCode == 201;
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

  final response = await http.delete(
    Uri.parse("$baseUrl/$id"),
  );

  return response.statusCode == 204;
}
Future<bool> technicianUpdateTicket(
  int id,
  String priority,
  String status,
  int technicianId,
  String notes,
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
      "notes": notes,
    }),
  );

  return response.statusCode == 204;
}
Future<List<Ticket>> getTechnicianTickets() async {
  final response = await http.get(
    Uri.parse("$baseUrl/Tickets/technician"),
  );

  if (response.statusCode == 200) {
    List data = jsonDecode(response.body);
    return data.map((e) => Ticket.fromJson(e)).toList();
  } else {
    throw Exception("Failed to load technician tickets");
  }
}

Future<TechnicianStats> getTechnicianStats() async {
  final url = "$baseUrl/Tickets/technician/stats";

  print("GET => $url");

  final response = await http.get(Uri.parse(url));

  print("Status: ${response.statusCode}");
  print("Body: ${response.body}");

  if (response.statusCode == 200) {
    return TechnicianStats.fromJson(jsonDecode(response.body));
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
}