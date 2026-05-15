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
  late Animation<double> _scaleAnim;
  bool _showRoleSelector = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
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
        context.go('/doctor');
      case DemoRole.patient:
        context.go('/patient');
      case DemoRole.receptionist:
        context.go('/receptionist');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1437), Color(0xFF0F1F4E), Color(0xFF0B1437)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Logo ──────────────────────────────────────────────────────
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              blurRadius: 32,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          color: Colors.white,
                          size: 46,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'MedLink',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your digital health companion',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // ── Role selector / loading ───────────────────────────────────
                if (!_showRoleSelector)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text('Loading...',
                            style: TextStyle(color: Colors.white24, fontSize: 12)),
                      ],
                    ),
                  )
                else
                  _RoleSelector(onSelect: _enterAs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Role selector ─────────────────────────────────────────────────────────────

class _RoleSelector extends StatelessWidget {
  final void Function(DemoRole) onSelect;
  const _RoleSelector({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'CONTINUE AS',
                  style: TextStyle(
                      color: Colors.white30,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5),
                ),
              ),
              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
            ],
          ),
          const SizedBox(height: 20),
          _RoleCard(
            label: 'Doctor',
            name: 'Dr. Arjun Mehta',
            subtitle: 'General Physician · Mumbai',
            icon: Icons.local_hospital_rounded,
            gradientColors: const [Color(0xFF1E40AF), Color(0xFF2563EB)],
            glowColor: const Color(0xFF2563EB),
            badgeLabel: 'MD',
            onTap: () => onSelect(DemoRole.doctor),
          ),
          const SizedBox(height: 12),
          _RoleCard(
            label: 'Patient',
            name: 'Riya Sharma',
            subtitle: '28 yrs · Female',
            icon: Icons.person_rounded,
            gradientColors: const [Color(0xFF065F46), Color(0xFF059669)],
            glowColor: const Color(0xFF059669),
            badgeLabel: 'ID',
            onTap: () => onSelect(DemoRole.patient),
          ),
          const SizedBox(height: 12),
          _RoleCard(
            label: 'Receptionist',
            name: 'Clinic Staff',
            subtitle: 'MedLink Clinic · Front Desk',
            icon: Icons.support_agent_rounded,
            gradientColors: const [Color(0xFF4C1D95), Color(0xFF7C3AED)],
            glowColor: const Color(0xFF7C3AED),
            badgeLabel: 'RX',
            onTap: () => onSelect(DemoRole.receptionist),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label, name, subtitle, badgeLabel;
  final IconData icon;
  final List<Color> gradientColors;
  final Color glowColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.name,
    required this.subtitle,
    required this.badgeLabel,
    required this.icon,
    required this.gradientColors,
    required this.glowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25), width: 1),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Arrow
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
