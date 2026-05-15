# Graph Report - C:\Users\mulgu\Desktop\APP\Doclink\lib  (2026-05-16)

## Corpus Check
- Corpus is ~42,132 words - fits in a single context window. You may not need a graph.

## Summary
- 785 nodes · 944 edges · 40 communities (39 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_AI Assistant Screen|AI Assistant Screen]]
- [[_COMMUNITY_App Shell & Router|App Shell & Router]]
- [[_COMMUNITY_Core Error & Data Layer|Core Error & Data Layer]]
- [[_COMMUNITY_Patient Booking & Payment|Patient Booking & Payment]]
- [[_COMMUNITY_Doctor Schedule|Doctor Schedule]]
- [[_COMMUNITY_Patient Home Screen|Patient Home Screen]]
- [[_COMMUNITY_Family Profiles|Family Profiles]]
- [[_COMMUNITY_Core Theme & Utilities|Core Theme & Utilities]]
- [[_COMMUNITY_Prescription Writer|Prescription Writer]]
- [[_COMMUNITY_Doctor Dashboard|Doctor Dashboard]]
- [[_COMMUNITY_Patient Records|Patient Records]]
- [[_COMMUNITY_Video & Chat Consultation|Video & Chat Consultation]]
- [[_COMMUNITY_Receptionist Manual Booking|Receptionist Manual Booking]]
- [[_COMMUNITY_Patient Waiting Room|Patient Waiting Room]]
- [[_COMMUNITY_Doctor Edit Profile|Doctor Edit Profile]]
- [[_COMMUNITY_Receptionist Reminders|Receptionist Reminders]]
- [[_COMMUNITY_Patient Payment History|Patient Payment History]]
- [[_COMMUNITY_Doctor Earnings|Doctor Earnings]]
- [[_COMMUNITY_Patient Appointments|Patient Appointments]]
- [[_COMMUNITY_Doctor Profile & QR|Doctor Profile & QR]]
- [[_COMMUNITY_Patient Profile|Patient Profile]]
- [[_COMMUNITY_Receptionist Queue Board|Receptionist Queue Board]]
- [[_COMMUNITY_Auth Splash Screen|Auth Splash Screen]]
- [[_COMMUNITY_Doctor Shell Navigation|Doctor Shell Navigation]]
- [[_COMMUNITY_Patient Shell Navigation|Patient Shell Navigation]]
- [[_COMMUNITY_Gemini AI Service|Gemini AI Service]]
- [[_COMMUNITY_Doctor Onboarding  KYC|Doctor Onboarding / KYC]]
- [[_COMMUNITY_Mock Data & Demo Mode|Mock Data & Demo Mode]]
- [[_COMMUNITY_User Onboarding Screen|User Onboarding Screen]]
- [[_COMMUNITY_Date Utilities|Date Utilities]]
- [[_COMMUNITY_Receptionist Shell Navigation|Receptionist Shell Navigation]]
- [[_COMMUNITY_Shell Scaffold Wrappers|Shell Scaffold Wrappers]]
- [[_COMMUNITY_Design System (ThemeWidgets)|Design System (Theme/Widgets)]]
- [[_COMMUNITY_Razorpay Native Payment|Razorpay Native Payment]]
- [[_COMMUNITY_Shared Skeleton Widgets|Shared Skeleton Widgets]]
- [[_COMMUNITY_Razorpay Web Stub|Razorpay Web Stub]]
- [[_COMMUNITY_Empty State Widget|Empty State Widget]]
- [[_COMMUNITY_Receptionist Shell|Receptionist Shell]]
- [[_COMMUNITY_App Constants|App Constants]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 43 edges
2. `../../core/theme/app_colors.dart` - 38 edges
3. `../../../../core/providers/app_providers.dart` - 30 edges
4. `package:flutter_riverpod/flutter_riverpod.dart` - 28 edges
5. `package:go_router/go_router.dart` - 18 edges
6. `../../../../core/theme/app_spacing.dart` - 18 edges
7. `../../../../core/services/gemini_service.dart` - 14 edges
8. `../../../../core/error/failures.dart` - 12 edges
9. `package:supabase_flutter/supabase_flutter.dart` - 8 edges
10. `app.dart` - 7 edges

## Surprising Connections (you probably didn't know these)
- `app.dart` --defines--> `DocLinkApp`  [EXTRACTED]
  main.dart → app.dart
- `app.dart` --defines--> `build`  [EXTRACTED]
  main.dart → app.dart
- `../../../../core/error/exceptions.dart` --defines--> `ServerException`  [EXTRACTED]
  features/auth/data/repositories/auth_repo_impl.dart → core/error/exceptions.dart
- `../../../../core/error/exceptions.dart` --defines--> `NetworkException`  [EXTRACTED]
  features/auth/data/repositories/auth_repo_impl.dart → core/error/exceptions.dart
- `../../../../core/error/exceptions.dart` --defines--> `AppAuthException`  [EXTRACTED]
  features/auth/data/repositories/auth_repo_impl.dart → core/error/exceptions.dart

## Communities (40 total, 1 thin omitted)

### Community 0 - "AI Assistant Screen"
Cohesion: 0.03
Nodes (66): AiAssistantScreen, _AiAssistantScreenState, _AiBadge, _AiCard, _body, build, _ChatBubble, _ChatInput (+58 more)

### Community 1 - "App Shell & Router"
Cohesion: 0.05
Nodes (40): app.dart, build, DocLinkApp, ApiConstants, AppAppointment, AppDoctor, AppFamilyMember, AppMedicine (+32 more)

### Community 2 - "Core Error & Data Layer"
Cohesion: 0.05
Nodes (38): AppAuthException, CacheException, NetworkException, ServerException, AuthFailure, CacheFailure, Failure, NetworkFailure (+30 more)

### Community 3 - "Patient Booking & Payment"
Cohesion: 0.06
Nodes (33): PaymentConfig, BookAppointmentScreen, _BookAppointmentScreenState, build, _buildStep, Center, Column, _ConfirmStep (+25 more)

### Community 4 - "Doctor Schedule"
Cohesion: 0.06
Nodes (31): _blockEntireDay, build, Center, _clearAllBlocks, Column, Container, _dateKey, _DateStrip (+23 more)

### Community 5 - "Patient Home Screen"
Cohesion: 0.06
Nodes (29): _ActionBtn, AppCard, build, Container, _EmptyCard, Expanded, _FamilyChip, Function (+21 more)

### Community 6 - "Family Profiles"
Cohesion: 0.07
Nodes (29): _ActionButton, _ActionsCard, addFamilyMember, build, Center, _colorFor, Column, _ConditionsCard (+21 more)

### Community 7 - "Core Theme & Utilities"
Cohesion: 0.08
Nodes (26): app_colors.dart, AppSpacing, AppTheme, Validators, build, dispose, initState, OtpScreen (+18 more)

### Community 8 - "Prescription Writer"
Cohesion: 0.07
Nodes (27): _addMedicine, _AppointmentPicker, build, _buildForm, _buildScaffold, Column, Container, copyWith (+19 more)

### Community 9 - "Doctor Dashboard"
Cohesion: 0.08
Nodes (23): _ActionBtn, build, _buildBody, Container, DoctorDashboardScreen, _EarningsCard, _EmptyState, Expanded (+15 more)

### Community 10 - "Patient Records"
Cohesion: 0.08
Nodes (23): build, Center, Color, Column, dispose, Divider, DlCard, Icon (+15 more)

### Community 11 - "Video & Chat Consultation"
Cohesion: 0.09
Nodes (22): Align, build, _ChatPanel, Container, _ControlBtn, dispose, _endCall, Expanded (+14 more)

### Community 12 - "Receptionist Manual Booking"
Cohesion: 0.09
Nodes (22): bookAppointment, build, _buildConfirmStep, _buildPatientStep, _buildSlotStep, _buildTypeStep, Column, _ConfirmRow (+14 more)

### Community 13 - "Patient Waiting Room"
Cohesion: 0.1
Nodes (20): build, Center, dispose, DlCard, Function, Icon, initState, _joinConsultation (+12 more)

### Community 14 - "Doctor Edit Profile"
Cohesion: 0.1
Nodes (19): BorderSide, build, Container, dispose, DoctorEditProfileScreen, _DoctorEditProfileScreenState, Expanded, _Field (+11 more)

### Community 15 - "Receptionist Reminders"
Cohesion: 0.1
Nodes (19): build, Center, Column, dispose, DlCard, initState, _MiniStat, _ReminderCard (+11 more)

### Community 16 - "Patient Payment History"
Cohesion: 0.1
Nodes (18): build, Center, Color, Column, Divider, DlCard, _EmptyState, Icon (+10 more)

### Community 17 - "Doctor Earnings"
Cohesion: 0.1
Nodes (19): BarChartGroupData, _BreakdownRow, build, _buildScaffold, Center, EarningsScreen, _EarningsScreenState, Expanded (+11 more)

### Community 18 - "Patient Appointments"
Cohesion: 0.1
Nodes (19): _AppointmentCard, _AppointmentCardState, _AppointmentList, build, _buildScaffold, Center, Color, dispose (+11 more)

### Community 19 - "Doctor Profile & QR"
Cohesion: 0.11
Nodes (18): build, _buildScaffold, Color, Column, DoctorProfileScreen, Icon, _InfoRow, Padding (+10 more)

### Community 20 - "Patient Profile"
Cohesion: 0.11
Nodes (18): build, Divider, DlCard, Expanded, _field, _HealthItem, PatientProfileScreen, _PatientProfileScreenState (+10 more)

### Community 21 - "Receptionist Queue Board"
Cohesion: 0.11
Nodes (18): build, _buildScreen, Container, dispose, Icon, initState, Opacity, PopupMenuItem (+10 more)

### Community 22 - "Auth Splash Screen"
Cohesion: 0.12
Nodes (15): build, dispose, Duration, GestureDetector, initState, _LoginButton, Padding, _RoleCard (+7 more)

### Community 23 - "Doctor Shell Navigation"
Cohesion: 0.13
Nodes (14): ../../../ai/presentation/screens/ai_assistant_screen.dart, AiAssistantScreen, build, DoctorProfileScreen, DoctorShellScreen, _DoctorShellScreenState, EarningsScreen, _navigate (+6 more)

### Community 24 - "Patient Shell Navigation"
Cohesion: 0.13
Nodes (14): build, FamilyProfilesScreen, _navigate, PatientAppointmentsScreen, PatientProfileScreen, PatientRecordsScreen, PatientShellScreen, _PatientShellScreenState (+6 more)

### Community 25 - "Gemini AI Service"
Cohesion: 0.14
Nodes (14): dispose, DrugInfo, _extractText, GeminiService, InteractionPair, InteractionResult, RxDraft, RxDrug (+6 more)

### Community 26 - "Doctor Onboarding / KYC"
Cohesion: 0.14
Nodes (13): _BasicInfoStep, build, _buildStep, Column, dispose, GestureDetector, KycScreen, _KycScreenState (+5 more)

### Community 27 - "Mock Data & Demo Mode"
Cohesion: 0.18
Nodes (10): DemoModeNotifier, MockAppointment, MockChatMessage, MockData, MockDoctor, MockEarningEntry, MockMedicine, MockPatient (+2 more)

### Community 28 - "User Onboarding Screen"
Cohesion: 0.18
Nodes (10): build, dispose, _next, _OnboardingPage, OnboardingScreen, _OnboardingScreenState, Padding, _PageContent (+2 more)

### Community 29 - "Date Utilities"
Cohesion: 0.18
Nodes (10): AppDateUtils, formatDate, formatDay, formatMonthYear, formatShort, formatTime, isSameDay, isToday (+2 more)

### Community 30 - "Receptionist Shell Navigation"
Cohesion: 0.2
Nodes (9): build, _navigate, ReceptionistShellScreen, _ReceptionistShellScreenState, Scaffold, TextStyle, manual_booking_screen.dart, queue_board_screen.dart (+1 more)

### Community 31 - "Shell Scaffold Wrappers"
Cohesion: 0.2
Nodes (8): build, DoctorShell, Scaffold, build, _currentIndex, PatientShell, Scaffold, package:go_router/go_router.dart

### Community 32 - "Design System (Theme/Widgets)"
Cohesion: 0.22
Nodes (8): AppColors, AppTypography, build, DlButton, SizedBox, ../../core/theme/app_colors.dart, package:flutter/material.dart, package:google_fonts/google_fonts.dart

### Community 33 - "Razorpay Native Payment"
Cohesion: 0.29
Nodes (6): dispose, Function, init, open, RazorpayService, package:razorpay_flutter/razorpay_flutter.dart

### Community 34 - "Shared Skeleton Widgets"
Cohesion: 0.29
Nodes (6): build, Container, DlSkeleton, DlSkeletonCard, SizedBox, package:shimmer/shimmer.dart

### Community 35 - "Razorpay Web Stub"
Cohesion: 0.33
Nodes (5): dispose, Function, init, open, RazorpayService

### Community 36 - "Empty State Widget"
Cohesion: 0.4
Nodes (4): build, Center, DlEmptyState, SizedBox

### Community 37 - "Receptionist Shell"
Cohesion: 0.4
Nodes (4): build, _currentIndex, ReceptionistShell, Scaffold

## Knowledge Gaps
- **701 isolated node(s):** `DocLinkApp`, `build`, `main`, `PaymentConfig`, `ApiConstants` (+696 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Design System (Theme/Widgets)` to `AI Assistant Screen`, `App Shell & Router`, `Patient Booking & Payment`, `Doctor Schedule`, `Patient Home Screen`, `Family Profiles`, `Core Theme & Utilities`, `Prescription Writer`, `Doctor Dashboard`, `Patient Records`, `Video & Chat Consultation`, `Receptionist Manual Booking`, `Patient Waiting Room`, `Doctor Edit Profile`, `Receptionist Reminders`, `Patient Payment History`, `Doctor Earnings`, `Patient Appointments`, `Doctor Profile & QR`, `Patient Profile`, `Receptionist Queue Board`, `Auth Splash Screen`, `Doctor Shell Navigation`, `Patient Shell Navigation`, `Doctor Onboarding / KYC`, `Mock Data & Demo Mode`, `User Onboarding Screen`, `Receptionist Shell Navigation`, `Shell Scaffold Wrappers`, `Shared Skeleton Widgets`, `Empty State Widget`, `Receptionist Shell`?**
  _High betweenness centrality (0.284) - this node is a cross-community bridge._
- **Why does `../../core/theme/app_colors.dart` connect `Design System (Theme/Widgets)` to `AI Assistant Screen`, `App Shell & Router`, `Patient Booking & Payment`, `Doctor Schedule`, `Patient Home Screen`, `Family Profiles`, `Core Theme & Utilities`, `Prescription Writer`, `Doctor Dashboard`, `Patient Records`, `Video & Chat Consultation`, `Receptionist Manual Booking`, `Patient Waiting Room`, `Doctor Edit Profile`, `Receptionist Reminders`, `Patient Payment History`, `Doctor Earnings`, `Patient Appointments`, `Doctor Profile & QR`, `Patient Profile`, `Receptionist Queue Board`, `Auth Splash Screen`, `Doctor Shell Navigation`, `Patient Shell Navigation`, `Doctor Onboarding / KYC`, `User Onboarding Screen`, `Receptionist Shell Navigation`, `Shell Scaffold Wrappers`, `Shared Skeleton Widgets`, `Empty State Widget`, `Receptionist Shell`?**
  _High betweenness centrality (0.232) - this node is a cross-community bridge._
- **Why does `package:flutter_riverpod/flutter_riverpod.dart` connect `App Shell & Router` to `Core Error & Data Layer`, `Patient Booking & Payment`, `Patient Home Screen`, `Family Profiles`, `Core Theme & Utilities`, `Prescription Writer`, `Doctor Dashboard`, `Patient Records`, `Receptionist Manual Booking`, `Patient Waiting Room`, `Doctor Edit Profile`, `Receptionist Reminders`, `Patient Payment History`, `Doctor Earnings`, `Patient Appointments`, `Doctor Profile & QR`, `Patient Profile`, `Receptionist Queue Board`, `Doctor Onboarding / KYC`?**
  _High betweenness centrality (0.111) - this node is a cross-community bridge._
- **What connects `DocLinkApp`, `build`, `main` to the rest of the system?**
  _701 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `AI Assistant Screen` be split into smaller, more focused modules?**
  _Cohesion score 0.03 - nodes in this community are weakly interconnected._
- **Should `App Shell & Router` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `Core Error & Data Layer` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._