import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/ticket.dart';
import '../models/technician.dart';
import '../theme/app_theme.dart';
import '../widgets/hotel_app_bar.dart';
import '../widgets/status_badge.dart';

class ManagerTicketDetailsPage extends StatefulWidget {
  final Ticket ticket;

  const ManagerTicketDetailsPage({
    super.key,
    required this.ticket,
  });

  @override
  State<ManagerTicketDetailsPage> createState() => _ManagerTicketDetailsPageState();
}

class _ManagerTicketDetailsPageState extends State<ManagerTicketDetailsPage> {
  final ApiService apiService = ApiService();

  List<Technician> technicians = [];
  Technician? selectedTechnician;
  bool isClosing = false;

  @override
  void initState() {
    super.initState();
    loadTechnicians();
  }

  Future<void> loadTechnicians() async {
    try {
      final result = await apiService.getTechnicians();
      setState(() {
        technicians = result;
        if (widget.ticket.technicianId != null) {
          selectedTechnician = technicians.firstWhere(
            (t) => t.userId == widget.ticket.technicianId,
            orElse: () => technicians.isNotEmpty ? technicians.first : Technician(userId: 0, fullName: "Unknown"),
          );
        }
      });
    } catch (e) {
      print("ERROR loading technicians: $e");
    }
  }

  Future<void> _openReassignDialog() async {
    Technician? tempSelected = selectedTechnician;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(widget.ticket.technicianId == null ? "Assign Technician" : "Reassign Technician"),
              content: DropdownButtonFormField<Technician>(
                initialValue: tempSelected,
                decoration: const InputDecoration(labelText: "Select Technician"),
                items: technicians.map((t) {
                  return DropdownMenuItem<Technician>(value: t, child: Text(t.fullName));
                }).toList(),
                onChanged: (value) => setDialogState(() => tempSelected = value),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: tempSelected == null ? null : () => Navigator.pop(context, true),
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || tempSelected == null) return;

    setState(() => selectedTechnician = tempSelected);

    try {
      await apiService.assignTechnician(widget.ticket.ticketId!, selectedTechnician!.userId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Technician assigned successfully")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to assign technician: $e")),
      );
    }
  }

  Future<void> _handleCloseTicket() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Close Ticket"),
        content: const Text(
          "Are you sure you want to close this ticket? This confirms the issue has been fully resolved and reviewed.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.priorityHigh, foregroundColor: Colors.white),
            child: const Text("Close Ticket"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isClosing = true);

    try {
      final success = await apiService.closeTicket(widget.ticket.ticketId!);

      if (!mounted) return;
      setState(() => isClosing = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ticket closed successfully.")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to close ticket.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isClosing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canClose = widget.ticket.status == "Resolved";

    return Scaffold(
      appBar: const HotelAppBar(title: "Ticket Details"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(widget.ticket.title, style: Theme.of(context).textTheme.headlineMedium)),
                const SizedBox(width: 12),
                StatusBadge(status: widget.ticket.status),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _DetailRow(label: "Department", value: widget.ticket.departmentName),
                  const Divider(height: 1),
                  _DetailRow(label: "Priority", valueWidget: PriorityBadge(priority: widget.ticket.priority)),
                  const Divider(height: 1),
                  _DetailRow(
                    label: "Assigned To",
                    value: widget.ticket.technicianId == null || widget.ticket.technicianName.isEmpty
                        ? "Not assigned"
                        : widget.ticket.technicianName,
                  ),
                  const Divider(height: 1),
                  _DetailRow(label: "Created At", value: widget.ticket.createdAt),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text("Description", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(widget.ticket.description, style: Theme.of(context).textTheme.bodyLarge),
            ),

            if (widget.ticket.technicianNotes?.isNotEmpty == true) ...[
              const SizedBox(height: 24),
              Text("Technician Notes", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(widget.ticket.technicianNotes!, style: Theme.of(context).textTheme.bodyLarge),
              ),
            ],

            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: technicians.isEmpty ? null : _openReassignDialog,
                    child: Text(widget.ticket.technicianId == null ? "Assign" : "Reassign"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (!canClose || isClosing) ? null : _handleCloseTicket,
                    child: isClosing
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.navy),
                          )
                        : const Text("Close Ticket"),
                  ),
                ),
              ],
            ),
            if (!canClose) ...[
              const SizedBox(height: 8),
              Text(
                "Tickets can only be closed once they're marked Resolved.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _DetailRow({required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          valueWidget ?? Text(value ?? "—", style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}