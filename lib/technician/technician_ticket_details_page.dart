import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';
import '../widgets/hotel_app_bar.dart';
import 'technician_update_ticket_page.dart';

class TechnicianTicketDetailsPage extends StatelessWidget {
  final Ticket ticket;
  final int technicianId;

  const TechnicianTicketDetailsPage({
    super.key,
    required this.ticket,
    required this.technicianId,
  });

  @override
  Widget build(BuildContext context) {
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
                Expanded(
                  child: Text(ticket.title, style: Theme.of(context).textTheme.headlineMedium),
                ),
                const SizedBox(width: 12),
                StatusBadge(status: ticket.status),
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
                  _DetailRow(label: "Department", value: ticket.departmentName),
                  const Divider(height: 1),
                  _DetailRow(label: "Priority", valueWidget: PriorityBadge(priority: ticket.priority)),
                  const Divider(height: 1),
                  _DetailRow(label: "Created At", value: ticket.createdAt),
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
              child: Text(ticket.description, style: Theme.of(context).textTheme.bodyLarge),
            ),

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
              child: Text(
                ticket.technicianNotes?.isNotEmpty == true ? ticket.technicianNotes! : "No technician notes yet",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: ticket.technicianNotes?.isNotEmpty == true
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
              ),
            ),

            if (ticket.category.isNotEmpty || ticket.suggestedPriority.isNotEmpty || ticket.suggestedSolution.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 18, color: AppColors.gold),
                        const SizedBox(width: 8),
                        Text("AI Analysis",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.navy)),
                      ],
                    ),
                    if (ticket.category.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text("Category", style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 2),
                      Text(ticket.category, style: Theme.of(context).textTheme.bodyLarge),
                    ],
                    if (ticket.suggestedPriority.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text("Suggested Priority", style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 2),
                      Text(ticket.suggestedPriority, style: Theme.of(context).textTheme.bodyLarge),
                    ],
                    if (ticket.suggestedSolution.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text("Suggested Solution", style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 2),
                      Text(ticket.suggestedSolution, style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Update Status — full update screen (status, priority, notes)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TechnicianUpdateTicketPage(
                        ticket: ticket,
                        technicianId: technicianId,
                        focusNotesOnly: false,
                      ),
                    ),
                  );
                  if (updated == true) {
                    if (!context.mounted) return;
                    Navigator.pop(context, true);
                  }
                },
                child: const Text("Update Status"),
              ),
            ),

            const SizedBox(height: 10),

            // Add Note — same update screen, just focused on the notes field
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TechnicianUpdateTicketPage(
                        ticket: ticket,
                        technicianId: technicianId,
                        focusNotesOnly: true,
                      ),
                    ),
                  );
                  if (updated == true) {
                    if (!context.mounted) return;
                    Navigator.pop(context, true);
                  }
                },
                child: const Text("Add Note"),
              ),
            ),

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