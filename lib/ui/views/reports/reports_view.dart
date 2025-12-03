import 'package:fetosense_remote_flutter/ui/widgets/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'reports_cubit.dart';
import 'reports_state.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportsCubit()..fetchReports(),
      child: const _ReportsBody(),
    );
  }
}

class _ReportsBody extends StatelessWidget {
  const _ReportsBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            _header(),
            Expanded(
              child: BlocBuilder<ReportsCubit, ReportsState>(
                builder: (context, state) {
                  print("STATE STATUS → ${state.status}");

                  if (state.status == ReportsStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == ReportsStatus.error) {
                    return Center(child: Text("Error: ${state.errorMessage}"));
                  }

                  final stats = context.read<ReportsCubit>().dashboardStats;

                  print("STATS SHOWN → $stats");

                  return Padding(
                    padding: const EdgeInsets.all(14),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: stats.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,           // 2 cards per row (best for mobile)
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      itemBuilder: (context, index) {
                        final item = stats[index];
                        return _statCard(item);
                      },
                    ),
                  );

                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(DashboardStat stat) {
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.teal.shade300, width: 1),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(stat.icon, color: Colors.teal, size: 30),
          const SizedBox(height: 12),
          Text(
            stat.count,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            stat.title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }


  Widget _header() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: Colors.teal)),
      ),
      child: ListTile(
        title: const Text('Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        subtitle: const Text('Overview of counts', style: TextStyle(fontSize: 12)),
        trailing: Image.asset('images/ic_logo_good.png', width: 36, height: 36),
      ),
    );
  }
}
