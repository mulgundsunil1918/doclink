import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/phone_login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';

// Doctor
import '../../features/doctor/presentation/screens/doctor_shell.dart';
import '../../features/doctor/presentation/screens/doctor_dashboard_screen.dart';
import '../../features/doctor/presentation/screens/schedule_screen.dart';
import '../../features/doctor/presentation/screens/doctor_profile_screen.dart';
import '../../features/doctor/presentation/screens/earnings_screen.dart';
import '../../features/ai/presentation/screens/ai_assistant_screen.dart';
import '../../features/doctor/presentation/screens/prescription_writer_screen.dart';
import '../../features/consultation/presentation/screens/video_call_screen.dart';
import '../../features/consultation/presentation/screens/chat_consultation_screen.dart';

// Patient
import '../../features/patient/presentation/screens/patient_shell.dart';
import '../../features/patient/presentation/screens/patient_home_screen.dart';
import '../../features/patient/presentation/screens/patient_appointments_screen.dart';
import '../../features/patient/presentation/screens/patient_records_screen.dart';
import '../../features/patient/presentation/screens/family_profiles_screen.dart';
import '../../features/patient/presentation/screens/patient_profile_screen.dart';
import '../../features/patient/presentation/screens/book_appointment_screen.dart';
import '../../features/patient/presentation/screens/waiting_room_screen.dart';
import '../../features/patient/presentation/screens/payment_history_screen.dart';

// Receptionist
import '../../features/receptionist/presentation/screens/receptionist_shell.dart';
import '../../features/receptionist/presentation/screens/queue_board_screen.dart';
import '../../features/receptionist/presentation/screens/manual_booking_screen.dart';
import '../../features/receptionist/presentation/screens/reminder_center_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    routerNeglect: kIsWeb,
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (ctx, _) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (ctx, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (ctx, _) => const PhoneLoginScreen(),
        routes: [
          GoRoute(
            path: 'otp',
            name: 'otp',
            builder: (ctx, state) {
              final phone = state.extra as String? ?? '';
              return OtpScreen(phone: phone);
            },
          ),
        ],
      ),

      // ── Doctor shell (StatefulShellRoute) ─────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (ctx, state, nav) => DoctorShell(navigationShell: nav),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/doctor/home',
              name: 'doctor-home',
              builder: (ctx, _) => const DoctorDashboardScreen(),
              routes: [
                GoRoute(
                  path: 'prescription',
                  name: 'prescription-writer',
                  builder: (ctx, _) => const PrescriptionWriterScreen(),
                ),
                GoRoute(
                  path: 'video-call',
                  name: 'doctor-video-call',
                  builder: (ctx, _) => const VideoCallScreen(),
                ),
                GoRoute(
                  path: 'chat',
                  name: 'doctor-chat',
                  builder: (ctx, _) => const ChatConsultationScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/doctor/schedule',
              name: 'doctor-schedule',
              builder: (ctx, _) => const ScheduleScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/doctor/qr',
              name: 'doctor-qr',
              builder: (ctx, _) => const DoctorProfileScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/doctor/earnings',
              name: 'doctor-earnings',
              builder: (ctx, _) => const EarningsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/doctor/ai',
              name: 'doctor-ai',
              builder: (ctx, _) => const AiAssistantScreen(),
            ),
          ]),
        ],
      ),

      // ── Patient shell (StatefulShellRoute) ────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (ctx, state, nav) => PatientShell(child: nav),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/patient/home',
              name: 'patient-home',
              builder: (ctx, _) => const PatientHomeScreen(),
              routes: [
                GoRoute(
                  path: 'book',
                  name: 'book-appointment',
                  builder: (ctx, _) => const BookAppointmentScreen(),
                ),
                GoRoute(
                  path: 'waiting-room',
                  name: 'waiting-room',
                  builder: (ctx, _) => const WaitingRoomScreen(),
                ),
                GoRoute(
                  path: 'video-call',
                  name: 'patient-video-call',
                  builder: (ctx, _) => const VideoCallScreen(),
                ),
                GoRoute(
                  path: 'chat',
                  name: 'patient-chat',
                  builder: (ctx, _) => const ChatConsultationScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/patient/appointments',
              name: 'patient-appointments',
              builder: (ctx, _) => const PatientAppointmentsScreen(),
              routes: [
                GoRoute(
                  path: 'payments',
                  name: 'payment-history',
                  builder: (ctx, _) => const PaymentHistoryScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/patient/records',
              name: 'patient-records',
              builder: (ctx, _) => const PatientRecordsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/patient/family',
              name: 'patient-family',
              builder: (ctx, _) => const FamilyProfilesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/patient/profile',
              name: 'patient-profile',
              builder: (ctx, _) => const PatientProfileScreen(),
            ),
          ]),
        ],
      ),

      // ── Receptionist shell (StatefulShellRoute) ───────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (ctx, state, nav) => ReceptionistShell(child: nav),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/receptionist/queue',
              name: 'queue-board',
              builder: (ctx, _) => const QueueBoardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/receptionist/booking',
              name: 'manual-booking',
              builder: (ctx, _) => const ManualBookingScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/receptionist/reminders',
              name: 'reminder-center',
              builder: (ctx, _) => const ReminderCenterScreen(),
            ),
          ]),
        ],
      ),
    ],
    errorBuilder: (ctx, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}',
            style: const TextStyle(color: Colors.grey)),
      ),
    ),
  );
});
