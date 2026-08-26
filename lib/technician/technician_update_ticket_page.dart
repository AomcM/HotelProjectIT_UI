import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hotel_app_bar.dart';

/// Matches the mockup's "Update Status" screen. Keeps all original
/// functionality (status, priority, notes) in one place — "Update Status"
/// and "Add Note" from the details page both open this screen;
/// `focusNotesOnly` just moves keyboard focus to the notes field first.
class TechnicianUpdateTicketPage extends StatefulWidget {
  final Ticket ticket;
  final int technicianId;
  final bool focusNotesOnly;

  const TechnicianUpdateTicketPage({
    super.key,
    required this.ticket,
    required this.technicianId,
    this.focusNotesOnly = false,
  });

  @override
  State<TechnicianUpdateTicketPage> createState() => _TechnicianUpdateTicketPageState();
}

class _TechnicianUpdateTicketPageState extends State<TechnicianUpdateTicketPage> {
  late String selectedStatus;
  late String selectedPriority;
  late TextEditingController notesController;
  final notesFocusNode = FocusNode();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.ticket.status;
    selectedPriority = widget.ticket.priority;
    notesController = TextEditingController(text: widget.ticket.technicianNotes ?? "");

    if (widget.focusNotesOnly) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notesFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    notesFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HotelAppBar(title: "Update Status"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Status", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedStatus,
              items: const [
                DropdownMenuItem(value: "Open", child: Text("Open")),
                DropdownMenuItem(value: "In Progress", child: Text("In Progress")),
                DropdownMenuItem(value: "Resolved", child: Text("Resolved")),
                // "Closed" intentionally omitted — only the Manager can close
                // a ticket, and only after reviewing a Resolved one.
              ],
              onChanged: (value) => setState(() => selectedStatus = value!),
            ),

            const SizedBox(height: 20),

            Text("Priority", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedPriority,
              items: const [
                DropdownMenuItem(value: "Pending", child: Text("Pending")),
                DropdownMenuItem(value: "Low", child: Text("Low")),
                DropdownMenuItem(value: "Medium", child: Text("Medium")),
                DropdownMenuItem(value: "High", child: Text("High")),
                DropdownMenuItem(value: "Critical", child: Text("Critical")),
              ],
              onChanged: (value) => setState(() => selectedPriority = value!),
            ),

            const SizedBox(height: 20),

            Text("Note", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              focusNode: notesFocusNode,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Working on the issue. Will update soon.",
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        setState(() => isSaving = true);

                        bool success = await ApiService().technicianUpdateTicket(
                          widget.ticket.ticketId!,
                          selectedPriority,
                          selectedStatus,
                          widget.technicianId,
                          notesController.text,
                        );

                        if (!mounted) return;
                        setState(() => isSaving = false);

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Ticket updated successfully")),
                          );
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Failed to update ticket")),
                          );
                        }
                      },
                child: isSaving
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.navy),
                      )
                    : const Text("Update"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}