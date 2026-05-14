import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

class FamilyProfilesScreen extends StatefulWidget {
  const FamilyProfilesScreen({super.key});
  @override
  State<FamilyProfilesScreen> createState() => _FamilyProfilesScreenState();
}

class _FamilyProfilesScreenState extends State<FamilyProfilesScreen> {
  int _active = 0;

  final _members = [
    _FamilyMember(
      name: 'Riya Sharma',
      relation: 'Self',
      age: 28,
      blood: 'B+',
      conditions: ['Hypertension'],
      visits: 6,
      avatar: 'RS',
      color: AppColors.patientPrimary,
    ),
    _FamilyMember(
      name: 'Suresh Sharma',
      relation: 'Father',
      age: 58,
      blood: 'O+',
      conditions: ['Diabetes', 'Hypertension'],
      visits: 12,
      avatar: 'SS',
      color: const Color(0xFF0891B2),
    ),
    _FamilyMember(
      name: 'Meena Sharma',
      relation: 'Mother',
      age: 54,
      blood: 'A+',
      conditions: ['Thyroid'],
      visits: 4,
      avatar: 'MS',
      color: const Color(0xFF7C3AED),
    ),
    _FamilyMember(
      name: 'Aryan Sharma',
      relation: 'Son',
      age: 5,
      blood: 'B+',
      conditions: [],
      visits: 2,
      avatar: 'AS',
      color: const Color(0xFFD97706),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final member = _members[_active];
    return Scaffold(
      backgroundColor: AppColors.patientSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Family Profiles',
            style: TextStyle(color: AppColors.slate800, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: AppColors.patientPrimary),
            onPressed: () => _showAddMemberSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Member selector strip
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(
                  _members.length,
                  (i) => _MemberAvatar(
                    member: _members[i],
                    selected: i == _active,
                    onTap: () => setState(() => _active = i),
                  ),
                ),
              ),
            ),
          ),
          // Profile detail
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _ProfileCard(member: member),
                  const SizedBox(height: 16),
                  _ConditionsCard(member: member),
                  const SizedBox(height: 16),
                  _QuickStatsCard(member: member),
                  const SizedBox(height: 16),
                  _ActionsCard(member: member),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    String relation = 'Spouse';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: StatefulBuilder(
          builder: (ctx, setLocal) => Column(
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
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: relation,
                decoration: const InputDecoration(
                  labelText: 'Relation',
                  border: OutlineInputBorder(),
                ),
                items: ['Spouse', 'Child', 'Parent', 'Sibling', 'Other']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setLocal(() => relation = v!),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${nameCtrl.text.isEmpty ? 'Member' : nameCtrl.text} added'),
                        backgroundColor: AppColors.patientPrimary,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.patientPrimary,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Add Member'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  final _FamilyMember member;
  final bool selected;
  final VoidCallback onTap;
  const _MemberAvatar({
    required this.member,
    required this.selected,
    required this.onTap,
  });

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
                color: selected
                    ? member.color
                    : member.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: member.color, width: 2.5)
                    : null,
              ),
              child: Center(
                child: Text(
                  member.avatar,
                  style: TextStyle(
                    color: selected ? Colors.white : member.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              member.relation,
              style: TextStyle(
                fontSize: 11,
                color: selected ? member.color : AppColors.slate500,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final _FamilyMember member;
  const _ProfileCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return DlCard(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: member.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(member.avatar,
                  style: TextStyle(
                      color: member.color, fontWeight: FontWeight.w700, fontSize: 20)),
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
                Text('${member.relation} • ${member.age} years',
                    style: const TextStyle(color: AppColors.slate500, fontSize: 13)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${member.blood} Blood Group',
                    style: const TextStyle(
                        color: Color(0xFFDC2626), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.slate400),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _ConditionsCard extends StatelessWidget {
  final _FamilyMember member;
  const _ConditionsCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return DlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.health_and_safety_rounded,
                  color: AppColors.patientPrimary, size: 18),
              const SizedBox(width: 8),
              const Text('Health Conditions',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate800,
                      fontSize: 14)),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.patientPrimary,
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero),
                child: const Text('+ Add', style: TextStyle(fontSize: 12)),
              ),
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
                        label: Text(c, style: const TextStyle(fontSize: 12)),
                        backgroundColor:
                            AppColors.patientPrimary.withValues(alpha: 0.1),
                        labelStyle:
                            const TextStyle(color: AppColors.patientPrimary),
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
  final _FamilyMember member;
  const _QuickStatsCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return DlCard(
      child: Row(
        children: [
          _StatItem(
            label: 'Total Visits',
            value: '${member.visits}',
            icon: Icons.local_hospital_rounded,
            color: AppColors.patientPrimary,
          ),
          _Divider(),
          _StatItem(
            label: 'Prescriptions',
            value: '${(member.visits * 0.8).round()}',
            icon: Icons.medication_rounded,
            color: AppColors.patientSecondary,
          ),
          _Divider(),
          _StatItem(
            label: 'Reports',
            value: '${(member.visits * 0.5).round()}',
            icon: Icons.description_rounded,
            color: const Color(0xFF7C3AED),
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
                  fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.slate500, fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 50, color: AppColors.slate100);
  }
}

class _ActionsCard extends StatelessWidget {
  final _FamilyMember member;
  const _ActionsCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return DlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.slate800, fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.calendar_month_rounded,
                  label: 'Book for ${member.relation}',
                  color: AppColors.patientPrimary,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.folder_rounded,
                  label: 'View Records',
                  color: AppColors.patientSecondary,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.upload_file_rounded,
                  label: 'Upload Report',
                  color: const Color(0xFF7C3AED),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.share_rounded,
                  label: 'Share Profile',
                  color: AppColors.slate500,
                  onTap: () {},
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
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _FamilyMember {
  final String name, relation, blood, avatar;
  final int age, visits;
  final List<String> conditions;
  final Color color;
  const _FamilyMember({
    required this.name,
    required this.relation,
    required this.age,
    required this.blood,
    required this.conditions,
    required this.visits,
    required this.avatar,
    required this.color,
  });
}
