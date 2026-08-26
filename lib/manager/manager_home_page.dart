import 'package:flutter/material.dart';
import '../models/technician.dart';
import '../models/manager_stats.dart';
import '../services/api_service.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import '../widgets/hotel_app_bar.dart';
import 'manager_ticket_details_page.dart';
import 'manager_tickets_page.dart';
import 'manager_reports_page.dart';
import 'manager_profile_page.dart';

class ManagerHomePage extends StatefulWidget {
  const ManagerHomePage({super.key});

  @override
  State<ManagerHomePage> createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends State<ManagerHomePage> {
  int currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = const [
      _DashboardTab(),
      ManagerTicketsPage(),
      ManagerReportsPage(),
      ManagerProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentTab, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (index) => setState(() => currentTab = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), label: 'Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  final ApiService apiService = ApiService();
  List<Ticket> tickets = [];
  final TextEditingController searchController = TextEditingController();

  String searchQuery = "";
  String selectedStatus = "All";

  List<Technician> technicians = [];
  ManagerStats? managerStats;

  List<Ticket> get filteredTickets {
    return tickets.where((ticket) {
      final matchesSearch = ticket.title.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesStatus = selectedStatus == "All" || ticket.status.toLowerCase() == selectedStatus.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    loadTechnicians();
    loadTickets();
    loadManagerStats();
  }

  Future<void> loadManagerStats() async {
    try {
      final result = await apiService.getManagerStats();
      setState(() => managerStats = result);
    } catch (e) {
      print("ERROR loading manager stats: $e");
    }
  }

  Future<void> loadTechnicians() async {
    try {
      final result = await apiService.getTechnicians();
      setState(() => technicians = result);
    } catch (e) {
      print("ERROR loading technicians: $e");
    }
  }

  Future<void> loadTickets() async {
    try {
      final result = await apiService.getManagerTickets();
      setState(() => tickets = result);
    } catch (e) {
      print("ERROR loading manager tickets: $e");
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([loadTickets(), loadManagerStats()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HotelAppBar(title: "IT Manager Dashboard"),
      body: RefreshIndicator(
        onRefresh: refreshAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _statusFilter("All"),
                    _statusFilter("Open"),
                    _statusFilter("In Progress"),
                    _statusFilter("Resolved"),
                    _statusFilter("Closed"),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: "Search tickets...",
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
                onChanged: (value) => setState(() => searchQuery = value),
              ),

              const SizedBox(height: 16),

              if (managerStats != null)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.7,
                  children: [
                    _statCard("Open", managerStats!.open, AppColors.statusOpen),
                    _statCard("In Progress", managerStats!.inProgress, AppColors.statusInProgress),
                    _statCard("Resolved", managerStats!.resolved, AppColors.statusResolved),
                    _statCard("Closed", managerStats!.closed, AppColors.statusClosed),
                  ],
                ),

              const SizedBox(height: 24),

              Text("Recent Tickets", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),

              if (tickets.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text("No tickets found")),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < filteredTickets.take(5).length; i++) ...[
                        InkWell(
                          onTap: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ManagerTicketDetailsPage(ticket: filteredTickets[i]),
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
                                      Text(filteredTickets[i].title, style: Theme.of(context).textTheme.titleMedium),
                                      const SizedBox(height: 2),
                                      Text(filteredTickets[i].departmentName, style: Theme.of(context).textTheme.bodyMedium),
                                    ],
                                  ),
                                ),
                                Text(
                                  filteredTickets[i].status,
                                  style: TextStyle(
                                    color: AppColors.statusColor(filteredTickets[i].status),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (i != filteredTickets.take(5).length - 1) const Divider(height: 1),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusFilter(String status) {
    final selected = selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(status),
        selected: selected,
        onSelected: (_) => setState(() => selectedStatus = status),
        selectedColor: AppColors.navy,
        backgroundColor: AppColors.surface,
        side: BorderSide(color: selected ? AppColors.navy : AppColors.border),
        labelStyle: TextStyle(
          color: selected ? AppColors.textOnDark : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
      ),
    );
  }

  Widget _statCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(count.toString(), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}