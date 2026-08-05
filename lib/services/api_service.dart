import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';
import '../models/department.dart';
import '../models/technician_stats.dart';
import '../models/login_response.dart';

class ApiService {

  static const String baseUrl = "http://localhost:5262/api";

  static const String departmentUrl =
      "http://localhost:5262/api/Departments";

  Future<List<Ticket>> getTickets() async {

    final response = await http.get(Uri.parse("$baseUrl/Tickets"));

    if (response.statusCode == 200) {

      List data = jsonDecode(response.body);

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
Future<bool> updateTechnicianTicket(
    int ticketId,
    String status,
    int technicianId,
) async {

  final response = await http.put(
    Uri.parse("$baseUrl/$ticketId/technician"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "status": status,
      "technicianId": technicianId,
    }),
  );

  return response.statusCode == 204;
}

Future<TechnicianStats> getTechnicianStats() async {
  final response = await http.get(
    Uri.parse("$baseUrl/technician/stats"),
  );

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
}