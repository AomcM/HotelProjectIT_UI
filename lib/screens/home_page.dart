import 'package:flutter/material.dart';
import '../../models/ticket.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import './ticket_details_page.dart';
import 'create_ticket_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tickets_list_page.dart';
import 'profile_page.dart';
import 'notifications_page.dart';
import '../../widgets/hotel_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int currentTab = 0;

  /// Called by the Home tab's "View All" button to jump to the
  /// My Tickets tab.
  void goToTicketsTab() {
    setState(() => currentTab = 1);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _HomeTab(onViewAllTickets: goToTicketsTab),
      const TicketsListPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (index) => setState(() => currentTab = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), label: 'My Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

/// The actual "Home" tab content — greeting, Create Ticket CTA,
/// and a preview of recent tickets.
class _HomeTab extends StatefulWidget {
  final VoidCallback onViewAllTickets;
  const _HomeTab({required this.onViewAllTickets});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final ApiService apiService = ApiService();
  late Future<List<Ticket>> tickets;
  String userName = "";
  List<Ticket> unseenClosedTickets = [];

  @override
  void initState() {
    super.initState();
    tickets = apiService.getMyTickets();
    tickets.then(_computeUnseenClosed);
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("name") ?? "";
    });
  }

  /// Compares fetched tickets against the locally-stored list of
  /// "seen" closed ticket ids to figure out which closed tickets this
  /// employee hasn't been notified about yet. Purely client-side —
  /// no backend notifications table involved.
  Future<void> _computeUnseenClosed(List<Ticket> allTickets) async {
    final prefs = await SharedPreferences.getInstance();
    final seenIds = (prefs.getStringList("seenClosedTicketIds") ?? [])
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .toSet();

    final closed = allTickets
        .where((t) => t.status == "Closed" && t.ticketId != null && !seenIds.contains(t.ticketId))
        .toList();

    if (!mounted) return;
    setState(() => unseenClosedTickets = closed);
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NotificationsPage(closedTickets: unseenClosedTickets)),
    );

    // Mark everything just shown as seen so the badge clears.
    final prefs = await SharedPreferences.getInstance();
    final seenIds = (prefs.getStringList("seenClosedTicketIds") ?? [])
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .toSet();
    seenIds.addAll(unseenClosedTickets.map((t) => t.ticketId!));
    await prefs.setStringList("seenClosedTicketIds", seenIds.map((e) => e.toString()).toList());

    if (!mounted) return;
    setState(() => unseenClosedTickets = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HotelAppBar(
        title: "Hotel IT",
        actions: [
          IconButton(
            icon: Badge(
              label: Text(unseenClosedTickets.length.toString()),
              isLabelVisible: unseenClosedTickets.isNotEmpty,
              child: const Icon(Icons.notifications_none),
            ),
            onPressed: _openNotifications,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            tickets = apiService.getMyTickets();
          });
          await tickets;
          await _computeUnseenClosed(await tickets);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName.isNotEmpty ? "Hello, $userName" : "Hello",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                "How can we help you?",
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 20),

              Material(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: () async {
                    final created = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateTicketPage(),
                      ),
                    );
                    if (created == true) {
                      setState(() {
                        tickets = apiService.getMyTickets();
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create New Ticket',
                                style: TextStyle(
                                  color: AppColors.textOnDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Report an issue',
                                style: TextStyle(color: AppColors.textOnDarkMuted, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: AppColors.navy, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Tickets', style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: widget.onViewAllTickets,
                    child: const Text('View All'),
                  ),
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

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text(snapshot.error.toString())),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text("No tickets found")),
                    );
                  }

                  // Preview: show up to 3 most recent tickets on Home
                  final ticketList = snapshot.data!.take(3).toList();

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
                                  builder: (_) => TicketDetailsPage(ticket: ticketList[i]),
                                ),
                              );
                              if (updated == true) {
                                setState(() {
                                  tickets = apiService.getMyTickets();
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      ticketList[i].title,
                                      style: Theme.of(context).textTheme.bodyLarge,
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
}