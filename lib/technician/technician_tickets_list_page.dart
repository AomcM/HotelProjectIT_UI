import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hotel_app_bar.dart';
import 'technician_ticket_details_page.dart';

class TechnicianTicketsListPage extends StatefulWidget {
  final int technicianId;
  const TechnicianTicketsListPage({super.key, required this.technicianId});

  @override
  State<TechnicianTicketsListPage> createState() => _TechnicianTicketsListPageState();
}

class _TechnicianTicketsListPageState extends State<TechnicianTicketsListPage> {
  final ApiService apiService = ApiService();
  late Future<List<Ticket>> tickets;
  String selectedFilter = "All";

  final filters = const ["All", "Open", "In Progress", "Resolved", "Closed"];

  @override
  void initState() {
    super.initState();
    tickets = apiService.getTechnicianTickets(technicianId: widget.technicianId, status: "All");
  }

  Future<void> _refresh() async {
    setState(() {
      tickets = apiService.getTechnicianTickets(technicianId: widget.technicianId, status: "All");
    });
    await tickets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HotelAppBar(title: "My Tickets"),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = filters[index];
                final selected = filter == selectedFilter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: selected,
                  onSelected: (_) => setState(() => selectedFilter = filter),
                  selectedColor: AppColors.navy,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(color: selected ? AppColors.navy : AppColors.border),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.textOnDark : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<Ticket>>(
                future: tickets,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return ListView(children: [Center(child: Text(snapshot.error.toString()))]);
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return ListView(children: const [Center(child: Text("No tickets found"))]);
                  }

                  final ticketList = snapshot.data!.where((t) {
                    if (selectedFilter == "All") return true;
                    return t.status.toLowerCase() == selectedFilter.toLowerCase();
                  }).toList();

                  if (ticketList.isEmpty) {
                    return Center(
                      child: Text("No \"$selectedFilter\" tickets", style: Theme.of(context).textTheme.bodyMedium),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: ticketList.length,
                    itemBuilder: (context, index) {
                      final ticket = ticketList[index];
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
                                builder: (_) => TechnicianTicketDetailsPage(
                                  ticket: ticket,
                                  technicianId: widget.technicianId,
                                ),
                              ),
                            );
                            if (updated == true) _refresh();
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