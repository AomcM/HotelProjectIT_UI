import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

/// Ticket row used in: Home "My Tickets", Technician "Assigned Tickets",
/// Manager "All Tickets" / "Recent Tickets".
///
/// Usage:
///   TicketCard(
///     title: ticket.title,
///     subtitle: ticket.location,
///     status: ticket.status,
///     onTap: () => Navigator.push(...),
///   )
class TicketCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String status;
  final VoidCallback? onTap;

  const TicketCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            StatusBadge(status: status),
          ],
        ),
      ),
    );
  }
}

/// The stat tile used on dashboards: "Open 4", "In Progress 6", etc.
/// Usage: StatTile(label: 'Open', value: '4', color: AppColors.statusOpen)
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const StatTile({super.key, required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color ?? AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}