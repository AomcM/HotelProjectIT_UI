import 'package:flutter/material.dart';
import '../../models/ticket.dart';
import '../../theme/app_theme.dart';
import '../../widgets/hotel_app_bar.dart';
import 'ticket_details_page.dart';

/// Shows tickets the manager has closed that this employee hasn't
/// acknowledged yet. Purely client-side — no backend "notifications"
/// table involved. The caller (Home tab) is responsible for marking
/// these as seen once this page is opened.
class NotificationsPage extends StatelessWidget {
  final List<Ticket> closedTickets;

  const NotificationsPage({super.key, required this.closedTickets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HotelAppBar(title: "Notifications"),
      body: closedTickets.isEmpty
          ? Center(
              child: Text("No new notifications", style: Theme.of(context).textTheme.bodyMedium),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: closedTickets.length,
              itemBuilder: (context, index) {
                final ticket = closedTickets[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.statusResolved.withValues(alpha: 0.4)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TicketDetailsPage(ticket: ticket)),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: AppColors.statusResolved, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Your ticket has been closed",
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(ticket.title, style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(height: 2),
                          Text(ticket.departmentName, style: Theme.of(context).textTheme.bodyMedium),
                          if (ticket.technicianNotes?.isNotEmpty == true) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Technician Note", style: Theme.of(context).textTheme.bodyMedium),
                                  const SizedBox(height: 4),
                                  Text(ticket.technicianNotes!, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}