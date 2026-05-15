import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

class PatientProfileScreen extends ConsumerStatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  ConsumerState<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends ConsumerState<PatientProfileScreen> {
  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) context.go('/login');
  }

  Future<void> _showEditSheet(AppPatient patient) async {
    final nameCtrl = TextEditingController(text: patient.name);
    final ageCtrl = TextEditingController(text: patient.age?.toString() ?? '');
    final addressCtrl = TextEditingController(text: patient.address ?? '');
    String? gender = patient.gender;
    String? bloodGroup = patient.bloodGroup;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Edit Profile',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx, false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _field(nameCtrl, 'Full Name', Icons.person_outline_rounded),
                  const SizedBox(height: 10),
                  _field(ageCtrl, 'Age', Icons.cake_outlined,
                      inputType: TextInputType.number),
                  const SizedBox(height: 10),
                  _field(addressCtrl, 'Address', Icons.location_on_outlined),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: gender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.wc_rounded, size: 20),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => gender = v),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: bloodGroup,
                    decoration: const InputDecoration(
                      labelText: 'Blood Group',
                      prefixIcon: Icon(Icons.bloodtype_outlined, size: 20),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                        .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                        .toList(),
                    onChanged: (v) => setState(() => bloodGroup = v),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.patientPrimary),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Save Changes'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (saved == true && mounted) {
      try {
        await updatePatientProfile(
          uid: patient.id,
          name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : null,
          age: int.tryParse(ageCtrl.text.trim()),
          gender: gender,
          bloodGroup: bloodGroup,
          address: addressCtrl.text.trim().isNotEmpty ? addressCtrl.text.trim() : null,
        );
        ref.invalidate(currentPatientProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated'), behavior: SnackBarBehavior.floating),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), behavior: SnackBarBehavior.floating),
          );
        }
      }
    }
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? inputType}) {
    return TextField(
      controller: ctrl,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientAsync = ref.watch(currentPatientProvider);
    final aptsAsync = ref.watch(patientAppointmentsProvider);
    final rxsAsync = ref.watch(patientPrescriptionsProvider);

    return patientAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const Scaffold(
          body: Center(child: Text('Failed to load profile'))),
      data: (patient) {
        final p = patient;
        final name = p?.name ?? 'Patient';
        final phone = p?.phone ?? '';
        final initials = p?.initials ?? 'P';
        final bloodGroup = p?.bloodGroup;
        final age = p?.age;
        final gender = p?.gender;

        final consultations =
            aptsAsync.valueOrNull?.length ?? 0;
        final prescriptions =
            rxsAsync.valueOrNull?.length ?? 0;

        return Scaffold(
          backgroundColor: AppColors.patientSurface,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.patientPrimary,
                actions: [
                  if (p != null)
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Colors.white),
                      tooltip: 'Edit profile',
                      onPressed: () => _showEditSheet(p),
                    ),
                ],
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
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white24,
                            child: Text(initials,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 24)),
                          ),
                          const SizedBox(height: 12),
                          Text(name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20)),
                          if (phone.isNotEmpty)
                            Text(phone,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13)),
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
                              _HealthItem(
                                  label: 'Blood Group',
                                  value: bloodGroup ?? '—'),
                              _HealthItem(
                                  label: 'Age',
                                  value: age != null ? '$age yrs' : '—'),
                              _HealthItem(
                                  label: 'Gender',
                                  value: gender ?? '—'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Quick stats
                    Row(
                      children: [
                        _QuickStat(
                            label: 'Consultations',
                            value: '$consultations',
                            icon: Icons.medical_services_rounded,
                            color: AppColors.patientPrimary),
                        const SizedBox(width: 12),
                        _QuickStat(
                            label: 'Prescriptions',
                            value: '$prescriptions',
                            icon: Icons.medication_rounded,
                            color: AppColors.patientSecondary),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Account section
                    _SettingsSection(title: 'Account', items: [
                      _SettingsItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Personal Information',
                          onTap: p != null ? () => _showEditSheet(p) : null),
                      _SettingsItem(
                          icon: Icons.language_rounded,
                          label: 'Language',
                          value: 'English',
                          onTap: null),
                      _SettingsItem(
                          icon: Icons.info_outline_rounded,
                          label: 'App Version',
                          value: 'v1.0.0',
                          onTap: null),
                    ]),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout_rounded,
                            color: Color(0xFFDC2626)),
                        label: const Text('Sign Out',
                            style: TextStyle(color: Color(0xFFDC2626))),
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
      },
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
                  color: AppColors.patientPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
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
  const _QuickStat(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DlCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
            Text(label,
                style: const TextStyle(
                    color: AppColors.slate500, fontSize: 11),
                textAlign: TextAlign.center),
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
                    leading:
                        Icon(item.icon, color: AppColors.patientPrimary, size: 20),
                    title: Text(item.label,
                        style: const TextStyle(
                            color: AppColors.slate800, fontSize: 14)),
                    trailing: item.value != null
                        ? Text(item.value!,
                            style: const TextStyle(
                                color: AppColors.slate400, fontSize: 13))
                        : item.onTap != null
                            ? const Icon(Icons.chevron_right_rounded,
                                color: AppColors.slate400)
                            : null,
                    onTap: item.onTap,
                    dense: true,
                  ),
                  if (item != items.last)
                    const Divider(
                        indent: 52,
                        endIndent: 0,
                        height: 1,
                        color: AppColors.slate100),
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
  const _SettingsItem(
      {required this.icon,
      required this.label,
      this.value,
      required this.onTap});
}
