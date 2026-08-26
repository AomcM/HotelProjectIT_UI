import 'dart:math';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/ticket.dart';
import '../models/manager_stats.dart';
import '../theme/app_theme.dart';
import '../widgets/hotel_app_bar.dart';

class ManagerReportsPage extends StatefulWidget {
  const ManagerReportsPage({super.key});

  @override
  State<ManagerReportsPage> createState() => _ManagerReportsPageState();
}

class _ManagerReportsPageState extends State<ManagerReportsPage> {
  final ApiService apiService = ApiService();
  ManagerStats? stats;
  List<Ticket> tickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        apiService.getManagerStats(),
        apiService.getManagerTickets(),
      ]);
      setState(() {
        stats = results[0] as ManagerStats;
        tickets = results[1] as List<Ticket>;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("ERROR loading reports data: $e");
    }
  }

  /// Groups tickets by department name -> count, sorted descending.
  Map<String, int> get departmentBreakdown {
    final Map<String, int> counts = {};
    for (final t in tickets) {
      final name = t.departmentName.isNotEmpty ? t.departmentName : "Unknown";
      counts[name] = (counts[name] ?? 0) + 1;
    }
    final entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HotelAppBar(title: "Reports"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tickets Overview", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),

                    if (stats != null)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CustomPaint(
                                painter: _DonutChartPainter(
                                  values: [
                                    stats!.open.toDouble(),
                                    stats!.inProgress.toDouble(),
                                    stats!.resolved.toDouble(),
                                    stats!.closed.toDouble(),
                                  ],
                                  colors: const [
                                    AppColors.statusOpen,
                                    AppColors.statusInProgress,
                                    AppColors.statusResolved,
                                    AppColors.statusClosed,
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _legendRow("Open", stats!.open, AppColors.statusOpen),
                                  const SizedBox(height: 10),
                                  _legendRow("In Progress", stats!.inProgress, AppColors.statusInProgress),
                                  const SizedBox(height: 10),
                                  _legendRow("Resolved", stats!.resolved, AppColors.statusResolved),
                                  const SizedBox(height: 10),
                                  _legendRow("Closed", stats!.closed, AppColors.statusClosed),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 28),

                    Text("Tickets by Department", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: departmentBreakdown.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: Text("No data yet")),
                            )
                          : Column(
                              children: [
                                for (final entry in departmentBreakdown.entries) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    child: Row(
                                      children: [
                                        Text(entry.key, style: Theme.of(context).textTheme.bodyLarge),
                                        const Spacer(),
                                        Text(
                                          entry.value.toString(),
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (entry.key != departmentBreakdown.keys.last) const Divider(height: 1),
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

  Widget _legendRow(String label, int value, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
        Text(value.toString(), style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

/// Simple donut chart — no external chart package required.
class _DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _DonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, v) => sum + v);
    if (total <= 0) return;

    final rect = Offset.zero & size;
    const strokeWidth = 18.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -pi / 2;

    for (int i = 0; i < values.length; i++) {
      if (values[i] <= 0) continue;
      final sweep = (values[i] / total) * 2 * pi;
      paint.color = colors[i];
      canvas.drawArc(
        rect.deflate(strokeWidth / 2),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}