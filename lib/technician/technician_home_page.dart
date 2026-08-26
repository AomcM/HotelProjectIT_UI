import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
import '../models/technician_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/hotel_app_bar.dart';
import 'technician_ticket_details_page.dart';
import 'technician_tickets_list_page.dart';
import 'technician_profile_page.dart';

class TechnicianHomePage extends StatefulWidget {
  final int technicianId;

  const TechnicianHomePage({
    super.key,
    required this.technicianId,
  });

  @override
  State<TechnicianHomePage> createState() => _TechnicianHomePageState();
}

class _TechnicianHomePageState extends State<TechnicianHomePage> {
  int currentTab = 0;

  void goToTicketsTab() => setState(() => currentTab = 1);

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _DashboardTab(technicianId: widget.technicianId, onViewAllTickets: goToTicketsTab),
      TechnicianTicketsListPage(technicianId: widget.technicianId),
      const TechnicianProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentTab, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (index) => setState(() => currentTab = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), label: 'My Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatefulWidget {
  final int technicianId;
  final VoidCallback onViewAllTickets;

  const _DashboardTab({required this.technicianId, required this.onViewAllTickets});

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  final ApiService apiService = ApiService();
  late Future<TechnicianStats> stats;
  late Future<List<Ticket>> tickets;
  int? technicianId;
  final TextEditingController searchController = TextEditingController();

  String searchText = "";
  String selectedFilter = "Open";

  @override
  void initState() {
    super.initState();
    loadTechnicianData();
  }

  Future<void> loadTechnicianData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTechnicianId = prefs.getInt("userId");

    if (savedTechnicianId == null) return;

    setState(() {
      technicianId = savedTechnicianId;
      tickets = apiService.getTechnicianTickets(technicianId: technicianId, status: "All");
      stats = apiService.getTechnicianStats(technicianId!);
    });
  }

  Future<void> refreshAll() async {
    if (technicianId == null) return;
    setState(() {
      tickets = apiService.getTechnicianTickets(technicianId: technicianId, status: "All");
      stats = apiService.getTechnicianStats(technicianId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HotelAppBar(
        title: "Technician Dashboard",
      ),
      body: RefreshIndicator(
        onRefresh: refreshAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: "Search tickets...",
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
                onChanged: (value) => setState(() => searchText = value.toLowerCase()),
              ),

              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip("Open"),
                    const SizedBox(width: 8),
                    _filterChip("In Progress"),
                    const SizedBox(width: 8),
                    _filterChip("Resolved"),
                    const SizedBox(width: 8),
                    _filterChip("Closed"),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3 stat tiles: Open / In Progress / Resolved
              FutureBuilder<TechnicianStats>(
                future: stats,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final s = snapshot.data!;
                  return Row(
                    children: [
                      Expanded(child: _statTile("Open", s.open, AppColors.statusOpen)),
                      const SizedBox(width: 10),
                      Expanded(child: _statTile("In Progress", s.inProgress, AppColors.statusInProgress)),
                      const SizedBox(width: 10),
                      Expanded(child: _statTile("Resolved", s.resolved, AppColors.statusResolved)),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("My Assigned Tickets", style: Theme.of(context).textTheme.titleLarge),
                  TextButton(onPressed: widget.onViewAllTickets, child: const Text("View All")),
                ],
              ),
              const SizedBox(height: 4),

              FutureBuilder<List<Ticket>>(
                future: tickets,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text("No tickets found")),
                    );
                  }

                  final ticketList = snapshot.data!
                      .where((t) =>
                          (t.title.toLowerCase().contains(searchText) ||
                              t.departmentName.toLowerCase().contains(searchText)) &&
                          (selectedFilter == "All" || t.status.toLowerCase() == selectedFilter.toLowerCase()))
                      .take(3)
                      .toList();

                  if (ticketList.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text("No \"$selectedFilter\" tickets", style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < ticketList.length; i++) ...[
                          InkWell(
                            onTap: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TechnicianTicketDetailsPage(
                                    ticket: ticketList[i],
                                    technicianId: widget.technicianId,
                                  ),
                                ),
                              );
                              if (updated == true) refreshAll();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(ticketList[i].title, style: Theme.of(context).textTheme.titleMedium),
                                        const SizedBox(height: 2),
                                        Text(ticketList[i].departmentName, style: Theme.of(context).textTheme.bodyMedium),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    ticketList[i].status,
                                    style: TextStyle(
                                      color: AppColors.statusColor(ticketList[i].status),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (i != ticketList.length - 1) const Divider(height: 1),
                        ],
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statTile(String label, int value, Color color) {
    final selected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: selected ? color : AppColors.border, width: selected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Text(value.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String status) {
    final selected = selectedFilter == status;
    return ChoiceChip(
      label: Text(status),
      selected: selected,
      onSelected: (_) => setState(() => selectedFilter = status),
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
  }
}