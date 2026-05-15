import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Skip all backend initialization — app runs on mock data for the demo.
  // Supabase.initialize() with placeholder credentials makes an HTTP
  // request that fails and prevents runApp() from being called.

  runApp(const ProviderScope(child: DocLinkApp()));
}
