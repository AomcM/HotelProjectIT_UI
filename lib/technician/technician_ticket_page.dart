import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';

class TechnicianTicketPage extends StatefulWidget {
  final Ticket ticket;

  const TechnicianTicketPage({
    super.key,
    required this.ticket,
  });

  @override
  State<TechnicianTicketPage> createState() =>
      _TechnicianTicketPageState();
}

class _TechnicianTicketPageState
    extends State<TechnicianTicketPage> {
  late String selectedPriority;
  late String selectedStatus;
  late int technicianId;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();

    selectedStatus = widget.ticket.status;
    selectedPriority = widget.ticket.priority;
    technicianId = widget.ticket.technicianId ?? 4;

 notesController = TextEditingController(
  text: widget.ticket.notes ?? "",
);
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Technician Ticket"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Title",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(widget.ticket.title),

            const SizedBox(height: 30),

            const Text(
              "Description",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(widget.ticket.description),

            const SizedBox(height: 20),

            const Text(
              "Department",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(widget.ticket.departmentName),

            const SizedBox(height: 20),

            const Divider(),

            const Text(
              "AI Analysis",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Category",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.ticket.category),

            const SizedBox(height: 20),

            const Text(
              "Suggested Priority",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.ticket.suggestedPriority),

            const SizedBox(height: 20),

            const Text(
              "Suggested Solution",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.ticket.suggestedSolution),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: selectedStatus,
              decoration: const InputDecoration(
                labelText: "Status",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Open",
                  child: Text("Open"),
                ),
                DropdownMenuItem(
                  value: "In Progress",
                  child: Text("In Progress"),
                ),
                DropdownMenuItem(
                  value: "Closed",
                  child: Text("Closed"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: selectedPriority,
              decoration: const InputDecoration(
                labelText: "Priority",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Pending",
                  child: Text("Pending"),
                ),
                DropdownMenuItem(
                  value: "Low",
                  child: Text("Low"),
                ),
                DropdownMenuItem(
                  value: "Medium",
                  child: Text("Medium"),
                ),
                DropdownMenuItem(
                  value: "High",
                  child: Text("High"),
                ),
                DropdownMenuItem(
                  value: "Critical",
                  child: Text("Critical"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedPriority = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Technician Notes",
                border: OutlineInputBorder(),
                hintText: "Write notes here...",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  bool success =
                      await ApiService().technicianUpdateTicket(
                    widget.ticket.ticketId!,
                    selectedPriority,
                    selectedStatus,
                    selectedStatus == "In Progress"
                        ? technicianId
                        : (widget.ticket.technicianId ?? technicianId),
                    notesController.text,
                  );

                  if (!mounted) return;

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Ticket updated successfully"),
                      ),
                    );

                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Failed to update ticket"),
                      ),
                    );
                  }
                },
                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}