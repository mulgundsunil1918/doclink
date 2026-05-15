import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'patient_home_screen.dart';
import 'patient_appointments_screen.dart';
import 'patient_records_screen.dart';
import 'family_profiles_screen.dart';
import 'patient_profile_screen.dart';

class PatientShellScreen extends StatefulWidget {
  const PatientShellScreen({super.key});
  @override
  State<PatientShellScreen> createState() => _PatientShellScreenState();
}

class _PatientShellScreenState extends State<PatientShellScreen> {
  int _index = 0;

  void _navigate(int i) => setState(() => _index = i);

  late final _screens = <Widget>[
    PatientHomeScreen(onNavigate: _navigate),
    const PatientAppointmentsScreen(),
    const PatientRecordsScreen(),
    const FamilyProfilesScreen(),
    const PatientProfileScreen(),
  ];

  static const _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Appointments'),
    BottomNavigationBarItem(icon: Icon(Icons.folder_rounded), label: 'Records'),
    BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Family'),
    BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
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
            selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
          ),
        ),
      ),
    );
  }
}
