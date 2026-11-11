import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'dashboard_screen.dart';

void main() {
  runApp(const SipWargaApp());
}

class SipWargaApp extends StatelessWidget {
  const SipWargaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIP-Warga',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const DashboardScreen(),
    );
  }
}
