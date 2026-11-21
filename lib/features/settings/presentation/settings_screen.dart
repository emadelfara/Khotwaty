import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../tracking/data/tracker_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TrackerRepository _repository = TrackerRepository();
  final TextEditingController _height = TextEditingController(text: AppConstants.defaultHeightCm.toStringAsFixed(0));
  final TextEditingController _weight = TextEditingController(text: AppConstants.defaultWeightKg.toStringAsFixed(0));
  bool _saving = false;

  @override
  void dispose() { _height.dispose(); _weight.dispose(); super.dispose(); }

  Future<void> _save() async {
    final height = double.tryParse(_height.text);
    final weight = double.tryParse(_weight.text);
    if (height == null || weight == null || height < 100 || height > 230 || weight < 25 || weight > 250) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('راجع الطول والوزن المدخلين.')));
      return;
    }
    setState(() => _saving = true);
    await _repository.saveProfile(heightCm: height, weightKg: weight);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ بياناتك.')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('الإعدادات')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const Text('بياناتك الشخصية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('تُستخدم لتقدير المسافة والسعرات بصورة أقرب للواقع.',
        style: TextStyle(color: AppTheme.muted)),
      const SizedBox(height: 18),
      TextField(controller: _height, keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'الطول بالسنتيمتر')),
      const SizedBox(height: 12),
      TextField(controller: _weight, keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'الوزن بالكيلوجرام')),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: _saving ? null : _save,
        icon: const Icon(Icons.save_outlined),
        label: Text(_saving ? 'جارٍ الحفظ...' : 'حفظ البيانات'),
      ),
      const SizedBox(height: 26),
      const Divider(color: AppTheme.surfaceAlt),
      const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.notifications_active_outlined, color: AppTheme.accent),
        title: Text('إشعارات الإنجاز'),
        subtitle: Text('إشعار عند الوصول إلى 5,000 و10,000 خطوة.'),
      ),
      const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.widgets_outlined, color: AppTheme.accent),
        title: Text('ويدجت الشاشة الرئيسية'),
        subtitle: Text('اضغط مطولاً على الشاشة الرئيسية ثم اختر Widgets ثم خُطوتي.'),
      ),
      const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.privacy_tip_outlined, color: AppTheme.accent),
        title: Text('خصوصيتك'),
        subtitle: Text('بيانات النشاط محفوظة محلياً على جهازك ولا يتم إرسالها إلى أي خادم.'),
      ),
      const Center(child: Text('خُطوتي • الإصدار 1.0.0',
        style: TextStyle(color: AppTheme.muted))),
    ]),
  );
}
