import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});
  @override
  State<PatientAppointmentsScreen> createState() =>
      _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apts = MockData.appointments;
    final upcoming = apts.where((a) => a.status == 'confirmed' || a.status == 'pending').toList();
    final ongoing = apts.where((a) => a.status == 'ongoing').toList();
    final past = apts.where((a) => a.status == 'completed').toList();

    return Scaffold(
      backgroundColor: AppColors.patientSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Appointments',
            style: TextStyle(color: AppColors.slate800, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.patientPrimary),
            onPressed: () => context.push('/patient/appointments/payments'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.patientPrimary,
          unselectedLabelColor: AppColors.slate400,
          indicatorColor: AppColors.patientPrimary,
          tabs: [
            Tab(text: 'Upcoming (${upcoming.length})'),
            Tab(text: 'Ongoing (${ongoing.length})'),
            Tab(text: 'Past (${past.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AppointmentList(appointments: upcoming, canJoin: true),
          _AppointmentList(appointments: ongoing, canJoin: true, isOngoing: true),
          _AppointmentList(appointments: past),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/patient/home/book'),
        backgroundColor: AppColors.patientPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Book New'),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List<MockAppointment> appointments;
  final bool canJoin;
  final bool isOngoing;
  const _AppointmentList({
    required this.appointments,
    this.canJoin = false,
    this.isOngoing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 48, color: AppColors.slate300),
            const SizedBox(height: 12),
            const Text('No appointments',
                style: TextStyle(color: AppColors.slate400, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: appointments.length,
      itemBuilder: (ctx, i) =>
          _AppointmentCard(apt: appointments[i], canJoin: canJoin, isOngoing: isOngoing),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final MockAppointment apt;
  final bool canJoin;
  final bool isOngoing;
  const _AppointmentCard({
    required this.apt,
    this.canJoin = false,
    this.isOngoing = false,
  });

  Color get _typeColor {
    switch (apt.type) {
      case 'video': return AppColors.patientPrimary;
      case 'audio': return AppColors.patientSecondary;
      case 'chat': return const Color(0xFF7C3AED);
      default: return AppColors.slate500;
    }
  }

  IconData get _typeIcon {
    switch (apt.type) {
      case 'video': return Icons.videocam_rounded;
      case 'audio': return Icons.phone_rounded;
      case 'chat': return Icons.chat_rounded;
      default: return Icons.local_hospital_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DlCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_typeIcon, color: _typeColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dr. Arjun Mehta',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate800,
                            fontSize: 14)),
                    Text('General Physician • Token #${apt.tokenNo}',
                        style: const TextStyle(
                            color: AppColors.slate500, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOngoing
                      ? const Color(0xFF059669).withValues(alpha: 0.1)
                      : _typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOngoing ? 'In Progress' : apt.time,
                  style: TextStyle(
                    color: isOngoing ? const Color(0xFF059669) : _typeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.patientSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.medical_information_rounded,
                    size: 14, color: AppColors.slate400),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(apt.chiefComplaint,
                      style: const TextStyle(color: AppColors.slate600, fontSize: 12)),
                ),
              ],
            ),
          ),
          if (canJoin) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.slate500,
                      side: const BorderSide(color: AppColors.slate200),
                      minimumSize: const Size(0, 36),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (apt.type == 'video') {
                        context.push('/patient/home/video-call');
                      } else if (apt.type == 'chat') {
                        context.push('/patient/home/chat');
                      } else {
                        context.push('/patient/home/waiting-room');
                      }
                    },
                    icon: Icon(_typeIcon, size: 14),
                    label: Text(
                      isOngoing ? 'Rejoin' : 'Join ${apt.type[0].toUpperCase()}${apt.type.substring(1)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _typeColor,
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
