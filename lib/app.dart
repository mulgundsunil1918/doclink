import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/clinic_theme.dart';

class DocLinkApp extends ConsumerWidget {
  const DocLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    // Watching the doctor's appearance choices here is what makes every setting
    // apply instantly across the app — no restart, no per-screen plumbing.
    final clinic = ref.watch(clinicThemeProvider);

    return MaterialApp.router(
      title: 'Doclink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.from(clinic, Brightness.light),
      darkTheme: AppTheme.from(clinic, Brightness.dark),
      themeMode: clinic.mode,
      routerConfig: router,
    );
  }
}
