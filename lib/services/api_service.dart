import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';

class ApiService {

  static const String baseUrl = "http://localhost:5262/api/Tickets";

  Future<List<Ticket>> getTickets() async {

    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {

      List data = jsonDecode(response.body);

      return data.map((e) => Ticket.fromJson(e)).toList();

    } else {

      throw Exception("Failed to load tickets");

    }
  }

  Future<bool> createTicket(Ticket ticket) async {

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(ticket.toJson()),
    );

    return response.statusCode == 200 ||
        response.statusCode == 201;
  }
}