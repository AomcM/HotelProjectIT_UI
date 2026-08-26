import 'package:flutter/material.dart';
import '../../models/ticket.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/hotel_app_bar.dart';
import '../../widgets/ticket_card.dart';
import 'ticket_details_page.dart';

class TicketsListPage extends StatefulWidget {
  const TicketsListPage({super.key});

  @override
  State<TicketsListPage> createState() => _TicketsListPageState();
}

class _TicketsListPageState extends State<TicketsListPage> {
  final ApiService apiService = ApiService();

  late Future<List<Ticket>> tickets;

  @override
  void initState() {
    super.initState();
    tickets = apiService.getMyTickets();
  }

  Future<void> _refresh() async {
    setState(() {
      tickets = apiService.getMyTickets();
    });
    await tickets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HotelAppBar(
        title: "My Tickets",
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Ticket>>(
          future: tickets,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No tickets found'));
            } else {
              final ticketList = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: ticketList.length,
                itemBuilder: (context, index) {
                  final ticket = ticketList[index];
                  return TicketCard(
                    title: ticket.title,
                    subtitle: ticket.departmentName,
                    status: ticket.status,
                    onTap: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TicketDetailsPage(ticket: ticket),
                        ),
                      );
                      if (updated == true) {
                        _refresh();
                      }
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}