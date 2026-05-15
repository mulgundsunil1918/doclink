import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

const _kRelations = ['Self', 'Spouse', 'Child', 'Parent', 'Sibling', 'Other'];
const _kBloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

const _kColors = [
  AppColors.patientPrimary,
  Color(0xFF0891B2),
  Color(0xFF7C3AED),
  Color(0xFFD97706),
  Color(0xFF059669),
];

class FamilyProfilesScreen extends ConsumerStatefulWidget {
  const FamilyProfilesScreen({super.key});
  @override
  ConsumerState<FamilyProfilesScreen> createState() =>
      _FamilyProfilesScreenState();
}

class _FamilyProfilesScreenState extends ConsumerState<FamilyProfilesScreen> {
  int _active = 0;

  Color _colorFor(int i) => _kColors[i % _kColors.length];

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(familyMembersProvider);
    final patientAsync = ref.watch(currentPatientProvider);

    return Scaffold(
      backgroundColor: AppColors.patientSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Family Profiles',
            style: TextStyle(
                color: AppColors.slate800, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded,
                color: AppColors.patientPrimary),
            onPressed: () => patientAsync.valueOrNull != null
                ? _showAddMemberSheet(context, patientAsync.valueOrNull!.id)
                : null,
          ),
        ],
      ),
      body: membersAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load profiles')),
        data: (members) {
          if (members.isEmpty) return _EmptyState(
            onAdd: () => patientAsync.valueOrNull != null
                ? _showAddMemberSheet(context, patientAsync.valueOrNull!.id)
                : null,
          );

          final idx = _active.clamp(0, members.length - 1);
          final member = members[idx];

          return Column(
            children: [
              // Member selector strip
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(members.length, (i) {
                      final m = members[i];
                      final color = _colorFor(i);
                      return _MemberAvatar(
                        name: m.name,
                        relation: m.relation,
                        color: color,
                        selected: i == idx,
                        onTap: () => setState(() => _active = i),
                      );
                    }),
                  ),
                ),
              ),
              // Profile detail
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _ProfileCard(member: member, color: _colorFor(idx)),
                      const SizedBox(height: 16),
                      _ConditionsCard(member: member),
                      const SizedBox(height: 16),
                      _QuickStatsCard(member: member),
                      const SizedBox(height: 16),
                      _ActionsCard(
                        member: member,
                        onBook: () => context.push('/patient/book'),
                        onRecords: () => context.push('/patient/records'),
                        onShare: () => Share.share(
                          'Family member profile\n'
                          'Name: ${member.name}\n'
                          'Relation: ${member.relation}\n'
                          'Age: ${member.age ?? "—"}\n'
                          'Blood Group: ${member.bloodGroup ?? "—"}\n'
                          'Conditions: ${member.conditions.isEmpty ? "None" : member.conditions.join(", ")}',
                          subject: '${member.name} — Health Profile',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddMemberSheet(BuildContext context, String patientId) {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    String relation = 'Spouse';
    String? bloodGroup;
    String? gender;
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Family Member',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate800)),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Full Name *', border: OutlineInputBorder()),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: relation,
                      decoration: const InputDecoration(
                          labelText: 'Relation', border: OutlineInputBorder()),
                      items: _kRelations
                          .map((r) =>
                              DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) => setLocal(() => relation = v!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Age', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: gender,
                      decoration: const InputDecoration(
                          labelText: 'Gender', border: OutlineInputBorder()),
                      items: ['Male', 'Female', 'Other']
                          .map((g) =>
                              DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (v) => setLocal(() => gender = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: bloodGroup,
                      decoration: const InputDecoration(
                          labelText: 'Blood Group',
                          border: OutlineInputBorder()),
                      items: _kBloodGroups
                          .map((b) =>
                              DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (v) => setLocal(() => bloodGroup = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (nameCtrl.text.trim().isEmpty) return;
                          setLocal(() => saving = true);
                          try {
                            await addFamilyMember(
                              patientId: patientId,
                              name: nameCtrl.text.trim(),
                              relation: relation,
                              age: int.tryParse(ageCtrl.text.trim()),
                              gender: gender,
                              bloodGroup: bloodGroup,
                            );
                            ref.invalidate(familyMembersProvider);
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${nameCtrl.text.trim()} added to family'),
                                  backgroundColor: AppColors.patientPrimary,
                                ),
                              );
                            }
                          } catch (e) {
                            setLocal(() => saving = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                    content: Text('Failed to add member')),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.patientPrimary,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Add Member'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback? onAdd;
  const _EmptyState({this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.family_restroom_rounded,
              size: 64, color: AppColors.slate300),
          const SizedBox(height: 16),
          const Text('No family members yet',
              style: TextStyle(
                  color: AppColors.slate500,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Add your family to book appointments for them',
              style: TextStyle(color: AppColors.slate400, fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Add Family Member'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.patientPrimary,
                foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  final String name, relation;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _MemberAvatar({
    required this.name,
    required this.relation,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: selected ? color : color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: selected ? Border.all(color: color, width: 2.5) : null,
              ),
              child: Center(
                child: Text(_initials,
                    style: TextStyle(
                        color: selected ? Colors.white : color,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ),
            ),
            const SizedBox(height: 4),
            Text(relation,
                style: TextStyle(
                    fontSize: 11,
                    color: selected ? color : AppColors.slate500,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final AppFamilyMember member;
  final Color color;
  const _ProfileCard({required this.member, required this.color});

  String get _initials {
    final parts = member.name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return member.name.isNotEmpty ? member.name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return DlCard(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(_initials,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 20)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate800,
                        fontSize: 16)),
                const SizedBox(height: 2),
                Text(
                  '${member.relation}${member.age != null ? " • ${member.age} years" : ""}${member.gender != null ? " • ${member.gender}" : ""}',
                  style: const TextStyle(
                      color: AppColors.slate500, fontSize: 13),
                ),
                if (member.bloodGroup != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${member.bloodGroup} Blood Group',
                      style: const TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConditionsCard extends StatelessWidget {
  final AppFamilyMember member;
  const _ConditionsCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return DlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.health_and_safety_rounded,
                  color: AppColors.patientPrimary, size: 18),
              SizedBox(width: 8),
              Text('Health Conditions',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate800,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          if (member.conditions.isEmpty)
            const Text('No known conditions',
                style: TextStyle(color: AppColors.slate400, fontSize: 13))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: member.conditions
                  .map((c) => Chip(
                        label: Text(c,
                            style: const TextStyle(fontSize: 12)),
                        backgroundColor:
                            AppColors.patientPrimary.withValues(alpha: 0.1),
                        labelStyle: const TextStyle(
                            color: AppColors.patientPrimary),
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _QuickStatsCard extends StatelessWidget {
  final AppFamilyMember member;
  const _QuickStatsCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return DlCard(
      child: Row(
        children: [
          _StatItem(
            label: 'Conditions',
            value: '${member.conditions.length}',
            icon: Icons.health_and_safety_rounded,
            color: AppColors.patientPrimary,
          ),
          _StatDivider(),
          _StatItem(
            label: 'Blood Group',
            value: member.bloodGroup ?? '—',
            icon: Icons.water_drop_rounded,
            color: const Color(0xFFDC2626),
          ),
          _StatDivider(),
          _StatItem(
            label: 'Age',
            value: member.age != null ? '${member.age}y' : '—',
            icon: Icons.cake_rounded,
            color: AppColors.patientSecondary,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.slate500, fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 50, color: AppColors.slate100);
}

class _ActionsCard extends StatelessWidget {
  final AppFamilyMember member;
  final VoidCallback onBook;
  final VoidCallback onRecords;
  final VoidCallback onShare;
  const _ActionsCard({
    required this.member,
    required this.onBook,
    required this.onRecords,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return DlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate800,
                  fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.calendar_month_rounded,
                  label: 'Book Appointment',
                  color: AppColors.patientPrimary,
                  onTap: onBook,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.folder_rounded,
                  label: 'View Records',
                  color: AppColors.patientSecondary,
                  onTap: onRecords,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.share_rounded,
                  label: 'Share Profile',
                  color: AppColors.slate500,
                  onTap: onShare,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
