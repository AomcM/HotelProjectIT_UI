import 'package:flutter/material.dart';
import '../../models/ticket.dart';
import '../../services/api_service.dart';

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
        title: const Text("Hotel IT Support"),
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

                  title: Text(ticket.title),

                  subtitle: Text(
                    "Priority: ${ticket.priority}\nStatus: ${ticket.status}",
                  ),

                  leading: const Icon(Icons.support_agent),

                ),

              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(

        onPressed: () {

        },

        child: const Icon(Icons.add),

      ),

    );
  }
}