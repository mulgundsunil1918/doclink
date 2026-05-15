import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

// Hardcoded fallback so the web app always starts even if .env fails to load.
const _supabaseUrl = 'https://zgjjenewtuwzqvhyvhei.supabase.co';
const _supabaseKey = 'sb_publishable_uep4nFEQ6TmTk1X7m2340w_zCTEH_Ic';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wrap in try-catch: on web the asset fetch can fail if service worker
  // is stale; we fall back to compile-time constants so the app always loads.
  String supabaseUrl = _supabaseUrl;
  String supabaseKey = _supabaseKey;
  try {
    await dotenv.load(fileName: '.env');
    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? _supabaseUrl;
    supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? _supabaseKey;
  } catch (_) {
    // Use compile-time fallback constants above.
  }

  final hasCredentials = supabaseUrl.isNotEmpty &&
      !supabaseUrl.contains('your-project') &&
      supabaseKey.isNotEmpty &&
      !supabaseKey.contains('your-anon-key');

  if (hasCredentials) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
  }

  runApp(const ProviderScope(child: DocLinkApp()));
}
