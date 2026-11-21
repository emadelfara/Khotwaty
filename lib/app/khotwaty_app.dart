import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/dashboard/presentation/main_shell.dart';

class KhotwatyApp extends StatelessWidget {
  const KhotwatyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'خُطوتي',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
    locale: const Locale('ar'),
    home: const Directionality(textDirection: TextDirection.rtl, child: MainShell()),
  );
}
