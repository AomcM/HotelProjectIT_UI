import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import '../widgets/hotel_app_bar.dart';
import 'manager_ticket_details_page.dart';

class ManagerTicketsPage extends StatefulWidget {
  const ManagerTicketsPage({super.key});

  @override
  State<ManagerTicketsPage> createState() => _ManagerTicketsPageState();
}

class _ManagerTicketsPageState extends State<ManagerTicketsPage> {
  final ApiService apiService = ApiService();
  List<Ticket> tickets = [];
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool isLoading = true;

  List<Ticket> get filteredTickets {
    return tickets.where((t) => t.title.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final result = await apiService.getManagerTickets();
      setState(() {
        tickets = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("ERROR loading manager tickets: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HotelAppBar(title: "All Tickets"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Search tickets...",
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: filteredTickets.isEmpty
                        ? ListView(
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(40),
                                child: Center(child: Text("No tickets found")),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            itemCount: filteredTickets.length,
                            itemBuilder: (context, index) {
                              final ticket = filteredTickets[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                  onTap: () async {
                                    final updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ManagerTicketDetailsPage(ticket: ticket),
                                      ),
                                    );
                                    if (updated == true) _load();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(ticket.title, style: Theme.of(context).textTheme.titleMedium),
                                              const SizedBox(height: 2),
                                              Text(ticket.departmentName, style: Theme.of(context).textTheme.bodyMedium),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          ticket.status,
                                          style: TextStyle(
                                            color: AppColors.statusColor(ticket.status),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}