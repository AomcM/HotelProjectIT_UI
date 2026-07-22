import 'package:flutter/material.dart';
import '../models/ticket.dart';

class TicketDetailsPage extends StatelessWidget {

  final Ticket ticket;

  const TicketDetailsPage({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Ticket Details"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              "Title",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(ticket.title),

            const SizedBox(height: 20),

            Text(
              "Description",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(ticket.description),

            const SizedBox(height: 20),

            Text(
              "Priority",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(ticket.priority),

            const SizedBox(height: 20),

            Text(
              "Status",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(ticket.status),

          ],

        ),

      ),

    );

  }

}