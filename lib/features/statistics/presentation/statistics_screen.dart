import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../tracking/data/tracker_repository.dart';
import '../../tracking/data/tracker_snapshot.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final TrackerRepository _repository = TrackerRepository();
  List<DailyRecord> _records = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final value = await _repository.getSnapshot();
    if (mounted) setState(() => _records = value.history.take(7).toList().reversed.toList());
  }

  @override
  Widget build(BuildContext context) {
    final total = _records.fold<int>(0, (sum, item) => sum + item.steps);
    final average = _records.isEmpty ? 0 : (total / _records.length).round();
    final yesterday = _records.length > 1 ? _records[_records.length - 2].steps : 0;
    final today = _records.isNotEmpty ? _records.last.steps : 0;
    final difference = today - yesterday;
    final maxSteps = _records.fold<int>(0, (a, b) => a > b.steps ? a : b.steps);
    return Scaffold(
      appBar: AppBar(title: const Text('إحصائياتك')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(padding: const EdgeInsets.all(18), children: [
          const Text('آخر 7 أيام', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          SizedBox(height: 230, child: Card(child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 22, 18, 12),
            child: _records.isEmpty
                ? const Center(child: Text('ابدأ تسجيل خطواتك لعرض الرسم البياني'))
                : BarChart(BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (maxSteps * 1.2).clamp(1000, double.infinity),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= _records.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(_records[index].date.substring(5),
                              style: const TextStyle(fontSize: 9, color: AppTheme.muted)),
                          );
                        },
                      )),
                    ),
                    barGroups: List.generate(_records.length, (index) {
                      final steps = _records[index].steps.toDouble();
                      return BarChartGroupData(x: index, barRods: [
                        BarChartRodData(
                          toY: steps, width: 18, borderRadius: BorderRadius.circular(6),
                          color: AppTheme.accent,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true, toY: 10000, color: Colors.white.withOpacity(.035)),
                        ),
                      ]);
                    }),
                  )),
          ))),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _StatCard(title: 'متوسط الخطوات',
              value: Formatters.steps(average), icon: Icons.analytics_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(title: 'إجمالي الأسبوع',
              value: Formatters.steps(total), icon: Icons.directions_walk)),
          ]),
          const SizedBox(height: 12),
          _StatCard(
            title: 'مقارنة اليوم بالأمس',
            value: difference == 0 ? 'لا توجد بيانات كافية'
                : '${difference > 0 ? '+' : ''}${Formatters.steps(difference)} خطوة',
            icon: Icons.compare_arrows,
          ),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon});
  final String title;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.all(17),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: AppTheme.accent),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
    ]),
  ));
}
