import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/dashboard_repository.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({this.bibleClubId, super.key});
  final String? bibleClubId;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final isNational = widget.bibleClubId == null;
    final asyncData = isNational
        ? ref.watch(nationalDashboardProvider)
        : ref.watch(bibleClubDashboardProvider(widget.bibleClubId!));

    return Scaffold(
      appBar: AppBar(
        title: Text(isNational ? 'Dashboard national' : 'Dashboard BBC'),
      ),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (d) => RefreshIndicator(
          onRefresh: () async {
            isNational
                ? ref.invalidate(nationalDashboardProvider)
                : ref.invalidate(
                    bibleClubDashboardProvider(widget.bibleClubId!));
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount:
                    MediaQuery.of(context).size.width > 600 ? 4 : 2,
                childAspectRatio: 1.4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  if (isNational)
                    _Stat(
                      label: 'Bible Clubs',
                      value: '${d.totalBibleClubs}',
                      icon: Icons.account_tree,
                    ),
                  _Stat(
                    label: 'Membres',
                    value: '${d.memberCount}',
                    icon: Icons.people,
                  ),
                  _Stat(
                    label: 'Fidèles',
                    value: '${d.faithfulCount}',
                    icon: Icons.verified,
                    color: AppColors.success,
                  ),
                  _Stat(
                    label: 'Réunions',
                    value: '${d.meetingCount}',
                    icon: Icons.event,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fidélité',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _FaithfulChart(
                        faithful: d.faithfulCount,
                        total: d.memberCount,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Présence par réunion',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _BarsChart(
                        attendance: d.totalAttendance,
                        meetings: d.meetingCount,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.primary,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color),
          Text(value,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _FaithfulChart extends StatelessWidget {
  const _FaithfulChart({required this.faithful, required this.total});
  final int faithful;
  final int total;

  @override
  Widget build(BuildContext context) {
    final remaining = (total - faithful).clamp(0, total).toDouble();
    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 50,
        sections: [
          PieChartSectionData(
            value: faithful.toDouble(),
            color: AppColors.success,
            title: '$faithful',
            radius: 60,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          PieChartSectionData(
            value: remaining,
            color: AppColors.surfaceAlt,
            title: '${remaining.toInt()}',
            radius: 60,
            titleStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarsChart extends StatelessWidget {
  const _BarsChart({required this.attendance, required this.meetings});
  final int attendance;
  final int meetings;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                final labels = ['Présence', 'Réunions'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child:
                      Text(labels[idx], style: const TextStyle(fontSize: 12)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(
              toY: attendance.toDouble(),
              gradient: AppColors.primaryGradient,
              width: 40,
              borderRadius: BorderRadius.circular(8),
            ),
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(
              toY: meetings.toDouble(),
              color: AppColors.accent,
              width: 40,
              borderRadius: BorderRadius.circular(8),
            ),
          ]),
        ],
      ),
    );
  }
}
