import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

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
