import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../tracking/data/tracker_repository.dart';
import '../../tracking/data/tracker_snapshot.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TrackerRepository _repository = TrackerRepository();
  List<DailyRecord> _records = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final snapshot = await _repository.getSnapshot();
    if (mounted) setState(() => _records = snapshot.history);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('سجل نشاطك')),
    body: RefreshIndicator(
      onRefresh: _load,
      child: _records.isEmpty
          ? ListView(children: const [
              SizedBox(height: 150),
              Icon(Icons.history, size: 54, color: AppTheme.muted),
              SizedBox(height: 12),
              Center(child: Text('لسه مفيش أيام مسجلة')),
              Center(child: Text('ابدأ المشي وسجل إنجازاتك هنا',
                style: TextStyle(color: AppTheme.muted))),
            ])
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _records[index];
                return Card(child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0x22EF3340),
                    child: Icon(Icons.directions_walk, color: AppTheme.accent),
                  ),
                  title: Text(Formatters.date(item.date),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${Formatters.km(item.distanceKm)} كم  •  ${Formatters.calories(item.calories)} كالوري'),
                  trailing: Text(Formatters.steps(item.steps),
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                ));
              },
            ),
    ),
  );
}
