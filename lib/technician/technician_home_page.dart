import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
import 'technician_ticket_page.dart';
import '../models/technician_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_page.dart';
class TechnicianHomePage extends StatefulWidget {
  final int technicianId;

  const TechnicianHomePage({
    super.key,
    required this.technicianId,
  });

  @override
  State<TechnicianHomePage> createState() =>
      _TechnicianHomePageState();
}
class _TechnicianHomePageState extends State<TechnicianHomePage> {

  final ApiService apiService = ApiService();
  late Future<TechnicianStats> stats;
  late Future<List<Ticket>> tickets;
  int? technicianId;
  final TextEditingController searchController = TextEditingController();

  String searchText = "";
  String selectedFilter = "Open";
  String selectedSort = "Priority";
  @override
void initState() {
  super.initState();

  loadTechnicianData();
}

Future<void> loadTechnicianData() async {
  final prefs = await SharedPreferences.getInstance();

  final savedTechnicianId = prefs.getInt("userId");

  if (savedTechnicianId == null) {
    print("ERROR: Technician ID not found");
    return;
  }

  setState(() {
    technicianId = savedTechnicianId;

    tickets = apiService.getTechnicianTickets(
      technicianId: technicianId,
      status: "All",
    );

    stats = apiService.getTechnicianStats(
      technicianId!,
    );
  });

  print("Logged-in Technician ID: $technicianId");
}
 Future<void> refreshTickets() async {
  if (technicianId == null) return;

  setState(() {
    tickets = apiService.getTechnicianTickets(
      technicianId: technicianId,
      status: selectedFilter,
    );
  });
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

     appBar: AppBar(
  title: const Text("Technician Dashboard"),
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

      body: Column(
  children: [

      Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search tickets...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            searchText = value.toLowerCase();
          });
        },
      ),
    ),
    Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12),
  child: Row(
    children: [

      const Text(
        "Sort by:",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),

      const SizedBox(width: 12),

      DropdownButton<String>(
        value: selectedSort,
        items: const [

          DropdownMenuItem(
            value: "Priority",
            child: Text("Priority"),
          ),

          DropdownMenuItem(
            value: "Newest",
            child: Text("Newest"),
          ),

          DropdownMenuItem(
            value: "Oldest",
            child: Text("Oldest"),
          ),
        ],
        onChanged: (value) {
          setState(() {
            selectedSort = value!;
          });
        },
      ),
    ],
  ),
),
    Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12),
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        filterButton("Open"),
        const SizedBox(width: 8),
        filterButton("In Progress"),
        const SizedBox(width: 8),
        filterButton("Closed"),
      ],
    ),
  ),
),
    FutureBuilder<TechnicianStats>(
      future: stats,
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }

        final s = snapshot.data!;
        
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [

              Expanded(
                child: buildStatCard(
                  "Open",
                  s.open,
                  Colors.blue,
                ),
              ),

              const SizedBox(width: 10),
             

              Expanded(
                child: buildStatCard(
                  "In Progress",
                  s.inProgress,
                  Colors.orange,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: buildStatCard(
                  "Closed",
                  s.closed,
                  Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    ),

    Expanded(
      child: FutureBuilder<List<Ticket>>(

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
        for (var ticket in snapshot.data!) {
          print("Ticket: ${ticket.title}");
          print("Status: '${ticket.status}'");
        }

        final ticketList = snapshot.data!
    .where((ticket) =>
        (ticket.title.toLowerCase().contains(searchText) ||
         ticket.description.toLowerCase().contains(searchText) ||
         ticket.departmentName.toLowerCase().contains(searchText) ||
         ticket.priority.toLowerCase().contains(searchText) ||
         ticket.status.toLowerCase().contains(searchText))
        &&
        (selectedFilter == "All" ||
        ticket.status.toLowerCase() == selectedFilter.toLowerCase()))
    .toList();
    if (selectedSort == "Priority") {
  const priorityOrder = {
    "Critical": 0,
    "High": 1,
    "Medium": 2,
    "Low": 3,
    "Pending": 4,
  };

  ticketList.sort((a, b) {
    return (priorityOrder[a.priority] ?? 99)
        .compareTo(priorityOrder[b.priority] ?? 99);
  });
}
else if (selectedSort == "Newest") {
  ticketList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
}
else if (selectedSort == "Oldest") {
  ticketList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
}
          return RefreshIndicator(

            onRefresh: refreshTickets,

            child: ListView.builder(

              itemCount: ticketList.length,

              itemBuilder: (context, index) {

                final ticket = ticketList[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                      ticket.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text("Department: ${ticket.departmentName}"),

                          const SizedBox(height: 6),

                          Row(
                            children: [

                              Chip(
                                label: Text(ticket.status),
                              ),

                              const SizedBox(width: 10),

                              Chip(
                                backgroundColor: getPriorityColor(ticket.priority),
                                label: Text(
                                  ticket.priority,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Text("Created: ${ticket.createdAt}"),
                        ],
                      ),
                    ),

                    trailing: const Icon(Icons.arrow_forward_ios),

                    onTap: () async {
          print("Logged-in technician ID: ${widget.technicianId}");
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          
                          builder: (_) => TechnicianTicketPage(
                          ticket: ticket,
                          technicianId: widget.technicianId,
                        ),
                        ),
                      );

                    if (updated == true) {
                        setState(() {
                          tickets = apiService.getTechnicianTickets(
                            technicianId: technicianId,
                            status: "All",
                          );

                          stats = apiService.getTechnicianStats(technicianId!);
                        });
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    ),
  ],
),
    );

  }
 Widget buildStatCard(String title, int value, Color color) {
  return GestureDetector(
    onTap: () {
  if (technicianId == null) return;

  setState(() {
    selectedFilter = title;

    tickets = apiService.getTechnicianTickets(
      technicianId: technicianId,
      status: title,
    );
  });
},
    child: Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
Widget filterButton(String status) {
  return ChoiceChip(
    label: Text(status),
    selected: selectedFilter == status,
    onSelected: (_) async {
      if (technicianId == null) return;

      setState(() {
        selectedFilter = status;
      });

      setState(() {
        if (status == "All") {
          tickets = apiService.getTechnicianTickets(
            technicianId: technicianId,
            status: "All",
          );
        } else if (status == "Open") {
          tickets = apiService.getTechnicianTickets(
            technicianId: technicianId,
            status: "Open",
          );
        } else if (status == "In Progress") {
          tickets = apiService.getTechnicianTickets(
            technicianId: technicianId,
            status: "In Progress",
          );
        } else if (status == "Closed") {
          tickets = apiService.getTechnicianTickets(
            technicianId: technicianId,
            status: "Closed",
          );
        }
      });
    },
  );
}

  Color getStatusColor(String status) {

  switch (status) {

    case "Open":
      return Colors.green;

    case "In Progress":
      return Colors.orange;

    case "Closed":
      return Colors.red;

    default:
      return Colors.grey;
  }
}
Color getPriorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case "critical":
      return Colors.red;

    case "high":
      return Colors.orange;

    case "medium":
      return Colors.amber;

    case "low":
      return Colors.green;

    default:
      return Colors.grey;
  }
}

}