import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/subscription_banner.dart';
import 'doctor_dashboard_screen.dart';
import 'schedule_screen.dart';
import 'doctor_profile_screen.dart';
import 'earnings_screen.dart';
import '../../../ai/presentation/screens/ai_assistant_screen.dart';

class DoctorShellScreen extends StatefulWidget {
  const DoctorShellScreen({super.key});
  @override
  State<DoctorShellScreen> createState() => _DoctorShellScreenState();
}

class _DoctorShellScreenState extends State<DoctorShellScreen> {
  int _index = 0;

  void _navigate(int i) => setState(() => _index = i);

  late final _screens = <Widget>[
    DoctorDashboardScreen(onNavigate: _navigate),
    const ScheduleScreen(),
    const DoctorProfileScreen(),
    const EarningsScreen(),
    const AiAssistantScreen(),
  ];

  static const _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: 'Schedule'),
    BottomNavigationBarItem(icon: Icon(Icons.qr_code_2_rounded), label: 'My QR'),
    BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Earnings'),
    BottomNavigationBarItem(icon: Icon(Icons.psychology_rounded), label: 'AI'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SubscriptionBanner(),
          Expanded(
            child: IndexedStack(index: _index, children: _screens),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: _navigate,
            items: _navItems,
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textMuted,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
          ),
        ),
      ),
    );
  }
}
