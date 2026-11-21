import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../tracking/data/tracker_repository.dart';
import '../../tracking/data/tracker_snapshot.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TrackerRepository _repository = TrackerRepository();
  TrackerSnapshot _snapshot = TrackerSnapshot.empty();
  Timer? _timer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 12), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final value = await _repository.getSnapshot();
    if (!mounted) return;
    setState(() { _snapshot = value; _loading = false; });
  }

  Future<bool> _requestPermissions() async {
    if (await _repository.requiresActivityPermission()) {
      final activity = await Permission.activityRecognition.request();
      if (!activity.isGranted) return false;
    }
    await Permission.notification.request();
    return true;
  }

  Future<void> _toggleTracking() async {
    if (_snapshot.isTracking) {
      await _repository.stop();
    } else {
      final granted = await _requestPermissions();
      if (!granted) {
        if (mounted) _showMessage('اسمح للتطبيق بالوصول إلى النشاط البدني لتشغيل عداد الخطوات.');
        return;
      }
      final started = await _repository.start();
      if (!started && mounted) {
        _showMessage(_snapshot.sensorAvailable
            ? 'تعذر تشغيل التتبع. تحقق من صلاحية النشاط البدني.'
            : 'هاتفك لا يوفّر مستشعر عدّاد الخطوات.');
      }
    }
    await _refresh();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_snapshot.steps / AppConstants.dailyGoal).clamp(0.0, 1.0).toDouble();
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.directions_walk, color: AppTheme.accent, size: 29),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('خُطوتي', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                Text('كل خطوة بتفرق', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
              ],
            )),
            IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded)),
          ]),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2B171B), Color(0xFF171922), Color(0xFF151922)],
                begin: Alignment.topRight, end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.accent.withOpacity(.24)),
            ),
            child: Column(children: [
              const Text('خطواتك النهارده', style: TextStyle(color: AppTheme.muted)),
              const SizedBox(height: 15),
              SizedBox(
                width: 190, height: 190,
                child: Stack(alignment: Alignment.center, children: [
                  SizedBox.expand(child: CircularProgressIndicator(
                    value: progress, strokeWidth: 12, strokeCap: StrokeCap.round,
                    backgroundColor: Colors.white.withOpacity(.07),
                    valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                  )),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.directions_walk, color: AppTheme.accent, size: 28),
                    const SizedBox(height: 5),
                    Text(Formatters.steps(_snapshot.steps),
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
                    const Text('خطوة', style: TextStyle(color: AppTheme.muted)),
                  ]),
                ]),
              ),
              const SizedBox(height: 17),
              Text('${(progress * 100).round()}% من هدفك اليومي • 8,000 خطوة',
                style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _toggleTracking,
                  icon: Icon(_snapshot.isTracking ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  label: Text(_snapshot.isTracking ? 'إيقاف التتبع' : 'بدء تتبع الخطوات'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _snapshot.isTracking ? AppTheme.surfaceAlt : AppTheme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              if (_snapshot.isTracking)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text('التتبع يعمل في الخلفية',
                    style: TextStyle(color: Color(0xFF65D6A3), fontSize: 12)),
                ),
            ]),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: _MetricCard(icon: Icons.route_rounded, title: 'المسافة',
              value: Formatters.km(_snapshot.distanceKm), unit: 'كم')),
            const SizedBox(width: 12),
            Expanded(child: _MetricCard(icon: Icons.local_fire_department_rounded,
              title: 'السعرات', value: Formatters.calories(_snapshot.calories), unit: 'كيلوكالوري')),
          ]),
          const SizedBox(height: 12),
          _MetricCard(icon: Icons.flag_rounded, title: 'المتبقي لهدفك',
            value: Formatters.steps((_snapshot.steps >= AppConstants.dailyGoal
                ? 0 : AppConstants.dailyGoal - _snapshot.steps)),
            unit: 'خطوة'),
          const SizedBox(height: 20),
          const Text('حالة المستشعر', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 7),
          Text(
            _snapshot.sensorAvailable
                ? 'مستشعر الخطوات متاح على جهازك.'
                : 'لم يتم اكتشاف مستشعر عدّاد الخطوات. قد لا يدعم هاتفك التتبع المباشر.',
            style: const TextStyle(color: AppTheme.muted, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon, required this.title, required this.value, required this.unit,
  });
  final IconData icon;
  final String title;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Row(children: [
        Icon(icon, color: AppTheme.accent, size: 25),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            Text(unit, style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
          ],
        )),
      ]),
    ),
  );
}
