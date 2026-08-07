import 'package:flutter/material.dart';
import '../models/ticket.dart';
import 'create_ticket_page.dart';
import '../services/api_service.dart';

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
        actions: [
  IconButton(
    icon: const Icon(Icons.edit),
    onPressed: () async {

      final updated = await Navigator.push(
        context,
        MaterialPageRoute(
         builder: (_) => CreateTicketPage(ticket: ticket),
        ),
      );

      if (updated == true) {
        Navigator.pop(context, true);
      }

    },
  ),
  IconButton(
  icon: const Icon(Icons.delete),
  onPressed: () async {

    // Ask for confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Ticket"),
          content: const Text(
            "Are you sure you want to delete this ticket?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    // User cancelled
    if (confirm != true) return;

    // Delete ticket
    bool success = await ApiService().deleteTicket(ticket.ticketId!);

    if (!context.mounted) return;

    if (success) {

      Navigator.pop(context, true);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete ticket"),
        ),
      );

    }
  },
),
],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Title",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(ticket.title),

            const SizedBox(height: 20),

            const Text(
              "Description",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(ticket.description),

            const SizedBox(height: 20),

            const Text(
              "Priority",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(ticket.priority),

            const SizedBox(height: 20),

            const Text(
              "Status",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(ticket.status),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 20),

            const Text(
              "AI Analysis",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Category",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(ticket.category),

           

            const SizedBox(height: 20),

            const Text(
              "Suggested Solution",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(ticket.suggestedSolution),

            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }
}