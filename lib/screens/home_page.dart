import 'package:flutter/material.dart';
import '../../models/ticket.dart';
import '../../services/api_service.dart';
import './ticket_details_page.dart';
import 'create_ticket_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final ApiService apiService = ApiService();

  late Future<List<Ticket>> tickets;

  @override
  void initState() {
    super.initState();

    tickets = apiService.getTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
  title: const Text("Hotel IT"),
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();

        await prefs.clear();

        if (!context.mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),
          (route) => false,
        );
      },
    ),
  ],
),

      body: FutureBuilder<List<Ticket>>(

        future: tickets,

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No tickets found"),
            );
          }

          final ticketList = snapshot.data!;

          return ListView.builder(

            itemCount: ticketList.length,

            itemBuilder: (context, index) {

              final ticket = ticketList[index];

              return Card(

                margin: const EdgeInsets.all(10),

                child: ListTile(

                      leading: const Icon(Icons.support_agent),

                      title: Text(ticket.title),

                      subtitle: Text(
                        "Priority: ${ticket.priority}\nStatus: ${ticket.status}",
                      ),

                      onTap: () async {

                        final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TicketDetailsPage(ticket: ticket),
                            ),
                          );

                              if (updated == true) {
                                setState(() {
                                  tickets = apiService.getTickets();
                                });
                              }

                          },

                        ),
              );
            },

          );
        },

      ),

     floatingActionButton: FloatingActionButton(
  onPressed: () async {
   final created = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateTicketPage(),
      ),
    );
     if (created == true) {
      setState(() {
        tickets = apiService.getTickets();
      });
    }
  },
  
  child: const Icon(Icons.add),
),

    );
  }
}