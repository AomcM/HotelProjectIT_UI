import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
import 'technician_ticket_page.dart';

class TechnicianHomePage extends StatefulWidget {
  const TechnicianHomePage({super.key});

  @override
  State<TechnicianHomePage> createState() => _TechnicianHomePageState();
}

class _TechnicianHomePageState extends State<TechnicianHomePage> {

  final ApiService apiService = ApiService();

  late Future<List<Ticket>> tickets;

  @override
  void initState() {
    super.initState();

    tickets = apiService.getTechnicianTickets();
  }

  Future<void> refreshTickets() async {
    setState(() {
      tickets = apiService.getTechnicianTickets();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("IT Technician Dashboard"),
      ),

      body: FutureBuilder<List<Ticket>>(

        future: tickets,

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No Open Tickets"),
            );
          }

          final ticketList = snapshot.data!;

          return RefreshIndicator(

            onRefresh: refreshTickets,

            child: ListView.builder(

              itemCount: ticketList.length,

              itemBuilder: (context, index) {

                final ticket = ticketList[index];

                return Card(

                  margin: const EdgeInsets.all(10),

                  child: ListTile(

                    title: Text(ticket.title),

                    subtitle: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        Text("Department: ${ticket.departmentName}"),

                        Text("Category: ${ticket.category}"),

                        Text("AI Priority: ${ticket.suggestedPriority}"),

                        Text("Status: ${ticket.status}"),

                      ],

                    ),

                    trailing: const Icon(Icons.arrow_forward),

                    onTap: () async {

                      final updated = await Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              TechnicianTicketPage(ticket: ticket),

                        ),

                      );

                      if (updated == true) {
                        refreshTickets();
                      }
                    },

                  ),

                );

              },

            ),

          );

        },

      ),

    );

  }

}