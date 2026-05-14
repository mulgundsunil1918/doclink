import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class DoctorShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const DoctorShell({super.key, required this.navigationShell});

  static const _tabs = [
    (icon: Icons.dashboard_rounded, label: 'Dashboard'),
    (icon: Icons.calendar_month_rounded, label: 'Schedule'),
    (icon: Icons.qr_code_rounded, label: 'My QR'),
    (icon: Icons.account_balance_wallet_rounded, label: 'Earnings'),
    (icon: Icons.smart_toy_rounded, label: 'AI'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.doctorCard,
        selectedItemColor: AppColors.doctorAccent,
        unselectedItemColor: AppColors.slate500,
        type: BottomNavigationBarType.fixed,
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
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
