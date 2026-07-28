import 'package:flutter/material.dart';
import '../models/ticket.dart';

class EditTicketPage extends StatelessWidget {
  final Ticket ticket;

  const EditTicketPage({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Ticket"),
      ),
      body: const Center(
        child: Text("Edit Ticket Page"),
      ),
    );
  }
}