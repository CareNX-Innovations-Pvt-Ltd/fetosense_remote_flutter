import 'package:flutter/material.dart';

/// Model representing a dashboard statistic item.
///
/// Each [DashboardStat] contains an [icon], a [title], and a [count] value to display on the dashboard.
class DashboardStat {
  /// The icon representing the statistic.
  final IconData icon;

  /// The title or label of the statistic.
  final String title;

  /// The count or value of the statistic.
  final String count;

  /// Creates a [DashboardStat] with the given [icon], [title], and [count].
  DashboardStat({required this.icon, required this.title, required this.count});

  /// Returns a copy of this [DashboardStat] with optional new values for its fields.
  ///
  /// If a parameter is not provided, the current value is used.
  DashboardStat copyWith({IconData? icon, String? title, String? count}) {
    return DashboardStat(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      count: count ?? this.count,
    );
  }
}

/// Mocked list of dashboard statistics for demonstration purposes.
///
/// Replace with real API data as needed.
final List<DashboardStat> dashboardStats = [
  DashboardStat(icon: Icons.business, title: "Organizations", count: "1"),
  DashboardStat(icon: Icons.devices, title: "Devices", count: "4"),
  DashboardStat(icon: Icons.pregnant_woman, title: "Mothers", count: "4121"),
  DashboardStat(icon: Icons.monitor_heart, title: "Tests", count: "5538"),
];

class DashboardStatsWidget extends StatelessWidget {
  final List<DashboardStat> stats;

  const DashboardStatsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      itemCount: stats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 12,
        childAspectRatio: 2.3,
      ),
      itemBuilder: (context, index) {
        final item = stats[index];
        return _DashboardStatCard(item: item);
      },
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final DashboardStat item;

  const _DashboardStatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              item.icon,
              size: 26,
              color: Colors.teal,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.count,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
