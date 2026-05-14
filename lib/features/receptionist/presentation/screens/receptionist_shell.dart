import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class ReceptionistShell extends StatelessWidget {
  final Widget child;
  const ReceptionistShell({super.key, required this.child});

  static const _tabs = [
    (icon: Icons.view_list_rounded, label: 'Queue', path: '/receptionist/queue'),
    (icon: Icons.add_box_rounded, label: 'Book', path: '/receptionist/booking'),
    (icon: Icons.notifications_rounded, label: 'Reminders', path: '/receptionist/reminders'),
  ];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    for (var i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.patientPrimary,
        unselectedItemColor: AppColors.slate400,
        type: BottomNavigationBarType.fixed,
        currentIndex: idx,
        onTap: (i) => context.go(_tabs[i].path),
        items: _tabs
            .map((t) => BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}
