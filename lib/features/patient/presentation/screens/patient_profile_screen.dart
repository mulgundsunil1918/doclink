import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.patientSurface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.patientPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.patientPrimary, Color(0xFF1D4ED8)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white24,
                        child: Text('RS',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24)),
                      ),
                      const SizedBox(height: 12),
                      const Text('Riya Sharma',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
                      const Text('+91 98765 43210',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Health summary
                DlCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Health Summary',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.slate800,
                              fontSize: 14)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _HealthItem(label: 'Blood Group', value: 'B+'),
                          _HealthItem(label: 'Age', value: '28 yrs'),
                          _HealthItem(label: 'Weight', value: '62 kg'),
                          _HealthItem(label: 'Height', value: '165 cm'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: ['Hypertension']
                            .map((c) => Chip(
                                  label: Text(c, style: const TextStyle(fontSize: 11)),
                                  backgroundColor:
                                      const Color(0xFFDC2626).withValues(alpha: 0.08),
                                  labelStyle: const TextStyle(color: Color(0xFFDC2626)),
                                  side: BorderSide.none,
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Quick stats
                Row(
                  children: [
                    _QuickStat(label: 'Consultations', value: '6', icon: Icons.medical_services_rounded, color: AppColors.patientPrimary),
                    const SizedBox(width: 12),
                    _QuickStat(label: 'Prescriptions', value: '5', icon: Icons.medication_rounded, color: AppColors.patientSecondary),
                    const SizedBox(width: 12),
                    _QuickStat(label: 'Reports', value: '3', icon: Icons.description_rounded, color: const Color(0xFF7C3AED)),
                  ],
                ),
                const SizedBox(height: 16),
                // Settings sections
                _SettingsSection(title: 'Account', items: [
                  _SettingsItem(icon: Icons.person_outline_rounded, label: 'Personal Information', onTap: () {}),
                  _SettingsItem(icon: Icons.location_on_outlined, label: 'Address', onTap: () {}),
                  _SettingsItem(icon: Icons.emergency_outlined, label: 'Emergency Contact', onTap: () {}),
                  _SettingsItem(icon: Icons.insert_drive_file_outlined, label: 'Documents & ID', onTap: () {}),
                ]),
                const SizedBox(height: 12),
                _SettingsSection(title: 'Preferences', items: [
                  _SettingsItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
                  _SettingsItem(icon: Icons.language_rounded, label: 'Language', value: 'English', onTap: () {}),
                  _SettingsItem(icon: Icons.dark_mode_outlined, label: 'Appearance', value: 'System', onTap: () {}),
                ]),
                const SizedBox(height: 12),
                _SettingsSection(title: 'About', items: [
                  _SettingsItem(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () {}),
                  _SettingsItem(icon: Icons.description_outlined, label: 'Terms of Service', onTap: () {}),
                  _SettingsItem(icon: Icons.info_outline_rounded, label: 'App Version', value: 'v1.0.0', onTap: null),
                ]),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
                    label: const Text('Sign Out', style: TextStyle(color: Color(0xFFDC2626))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDC2626)),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthItem extends StatelessWidget {
  final String label, value;
  const _HealthItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: AppColors.patientPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
          Text(label,
              style: const TextStyle(color: AppColors.slate500, fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _QuickStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DlCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 18)),
            Text(label, style: const TextStyle(color: AppColors.slate500, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;
  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return DlCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title,
                style: const TextStyle(
                    color: AppColors.slate500,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
          ),
          ...items.map((item) => Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: AppColors.patientPrimary, size: 20),
                    title: Text(item.label,
                        style: const TextStyle(color: AppColors.slate800, fontSize: 14)),
                    trailing: item.value != null
                        ? Text(item.value!,
                            style: const TextStyle(color: AppColors.slate400, fontSize: 13))
                        : item.onTap != null
                            ? const Icon(Icons.chevron_right_rounded, color: AppColors.slate400)
                            : null,
                    onTap: item.onTap,
                    dense: true,
                  ),
                  if (item != items.last)
                    const Divider(
                        indent: 52, endIndent: 0, height: 1, color: AppColors.slate100),
                ],
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  const _SettingsItem({required this.icon, required this.label, this.value, required this.onTap});
}
