import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  bool _showRoleSelector = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _showRoleSelector = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _enterAs(DemoRole role) {
    demoMode.setRole(role);
    switch (role) {
      case DemoRole.doctor:
        context.go('/doctor/home');
      case DemoRole.patient:
        context.go('/patient/home');
      case DemoRole.receptionist:
        context.go('/receptionist/queue');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.doctorSurface,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.doctorPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Doclink',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your digital practice. Your rules.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.slate400,
                    ),
              ),
              const SizedBox(height: 60),
              if (!_showRoleSelector)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.doctorAccent,
                  ),
                )
              else
                _RoleSelector(onSelect: _enterAs),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final void Function(DemoRole) onSelect;
  const _RoleSelector({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Text(
            'Continue as',
            style: TextStyle(color: AppColors.slate400, fontSize: 13),
          ),
          const SizedBox(height: 16),
          _RoleButton(
            label: 'Doctor',
            subtitle: 'Dr. Arjun Mehta',
            icon: Icons.medical_services_rounded,
            color: AppColors.doctorAccent,
            onTap: () => onSelect(DemoRole.doctor),
          ),
          const SizedBox(height: 10),
          _RoleButton(
            label: 'Patient',
            subtitle: 'Riya Sharma',
            icon: Icons.person_rounded,
            color: AppColors.patientPrimary,
            onTap: () => onSelect(DemoRole.patient),
          ),
          const SizedBox(height: 10),
          _RoleButton(
            label: 'Receptionist',
            subtitle: 'Clinic Staff',
            icon: Icons.support_agent_rounded,
            color: const Color(0xFF7C3AED),
            onTap: () => onSelect(DemoRole.receptionist),
          ),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _RoleButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: color, fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(subtitle,
                      style: const TextStyle(color: AppColors.slate400, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
          ],
        ),
      ),
    );
  }
}
