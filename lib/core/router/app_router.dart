import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/phone_login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/doctor/presentation/screens/doctor_shell_screen.dart';
import '../../features/doctor/presentation/screens/prescription_writer_screen.dart';
import '../../features/patient/presentation/screens/patient_shell_screen.dart';
import '../../features/receptionist/presentation/screens/receptionist_shell_screen.dart';
import '../../features/consultation/presentation/screens/video_call_screen.dart';
import '../../features/consultation/presentation/screens/chat_consultation_screen.dart';
import '../../features/patient/presentation/screens/book_appointment_screen.dart';
import '../../features/patient/presentation/screens/waiting_room_screen.dart';
import '../../features/ai/presentation/screens/ai_assistant_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(path: '/', builder: (ctx, _) => const SplashScreen()),
      GoRoute(
        path: '/login',
        builder: (ctx, _) => const PhoneLoginScreen(),
        routes: [
          GoRoute(
            path: 'otp',
            name: 'otp',
            builder: (ctx, state) =>
                OtpScreen(phone: state.extra as String? ?? ''),
          ),
        ],
      ),
      GoRoute(
        path: '/doctor',
        builder: (ctx, _) => const DoctorShellScreen(),
        routes: [
          GoRoute(
              path: 'video-call',
              builder: (ctx, _) => const VideoCallScreen()),
          GoRoute(
            path: 'chat',
            builder: (ctx, state) => ChatConsultationScreen(
              appointmentId: state.extra as String? ?? '',
            ),
          ),
          GoRoute(
            path: 'rx',
            builder: (ctx, state) {
              final extra = state.extra as Map<String, String?>?;
              return PrescriptionWriterScreen(
                patientName: extra?['patientName'],
                patientId: extra?['patientId'],
                appointmentId: extra?['appointmentId'],
              );
            },
          ),
          GoRoute(
            path: 'ai',
            builder: (ctx, state) {
              final extra = state.extra as Map<String, String?>?;
              return AiAssistantScreen(
                patientName: extra?['patientName'],
                patientId: extra?['patientId'],
                appointmentId: extra?['appointmentId'],
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/patient',
        builder: (ctx, _) => const PatientShellScreen(),
        routes: [
          GoRoute(
              path: 'book',
              builder: (ctx, _) => const BookAppointmentScreen()),
          GoRoute(
              path: 'waiting-room',
              builder: (ctx, state) => WaitingRoomScreen(
                    appointmentId: state.extra as String?,
                  )),
          GoRoute(
              path: 'video-call',
              builder: (ctx, _) => const VideoCallScreen()),
          GoRoute(
            path: 'chat',
            builder: (ctx, state) => ChatConsultationScreen(
              appointmentId: state.extra as String? ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/receptionist',
        builder: (ctx, _) => const ReceptionistShellScreen(),
      ),
    ],
    errorBuilder: (ctx, state) => Scaffold(
      body: Center(child: Text('Not found: ${state.uri}')),
    ),
  );
});
