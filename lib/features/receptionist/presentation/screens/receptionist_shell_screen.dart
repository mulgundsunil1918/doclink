import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'queue_board_screen.dart';
import 'manual_booking_screen.dart';
import 'reminder_center_screen.dart';

class ReceptionistShellScreen extends StatefulWidget {
  const ReceptionistShellScreen({super.key});
  @override
  State<ReceptionistShellScreen> createState() => _ReceptionistShellScreenState();
}

class _ReceptionistShellScreenState extends State<ReceptionistShellScreen> {
  int _index = 0;

  void _navigate(int i) => setState(() => _index = i);

  static const _screens = <Widget>[
    QueueBoardScreen(),
    ManualBookingScreen(),
    ReminderCenterScreen(),
  ];

  static const _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.view_list_rounded), label: 'Queue'),
    BottomNavigationBarItem(icon: Icon(Icons.add_box_rounded), label: 'Book'),
    BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Reminders'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
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
            selectedLabelStyle:
                const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
          ),
        ),
      ),
    );
  }
}
