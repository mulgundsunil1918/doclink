import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class PatientShell extends StatelessWidget {
  final Widget child;
  const PatientShell({super.key, required this.child});

  static const _tabs = [
    (icon: Icons.home_rounded, label: 'Home', path: '/patient/home'),
    (icon: Icons.calendar_month_rounded, label: 'Appointments', path: '/patient/appointments'),
    (icon: Icons.description_rounded, label: 'Records', path: '/patient/records'),
    (icon: Icons.people_rounded, label: 'Family', path: '/patient/family'),
    (icon: Icons.person_rounded, label: 'Profile', path: '/patient/profile'),
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
