# Graph Report - C:\Users\mulgu\Desktop\APP\Doclink  (2026-05-15)

## Corpus Check
- Corpus is ~32,468 words - fits in a single context window. You may not need a graph.

## Summary
- 708 nodes · 802 edges · 56 communities (45 shown, 11 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 9 edges (avg confidence: 0.93)
- Token cost: 30,525 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Dependencies & Config|Dependencies & Config]]
- [[_COMMUNITY_Auth Data Layer|Auth Data Layer]]
- [[_COMMUNITY_App Entry & Routing|App Entry & Routing]]
- [[_COMMUNITY_Chat Consultation UI|Chat Consultation UI]]
- [[_COMMUNITY_Patient Appointments UI|Patient Appointments UI]]
- [[_COMMUNITY_Appointment Booking Flow|Appointment Booking Flow]]
- [[_COMMUNITY_Theme & Auth Screens|Theme & Auth Screens]]
- [[_COMMUNITY_Onboarding Flow|Onboarding Flow]]
- [[_COMMUNITY_Family Profiles UI|Family Profiles UI]]
- [[_COMMUNITY_Patient Home Dashboard|Patient Home Dashboard]]
- [[_COMMUNITY_Patient Records UI|Patient Records UI]]
- [[_COMMUNITY_Receptionist Reminders|Receptionist Reminders]]
- [[_COMMUNITY_Prescription Writer|Prescription Writer]]
- [[_COMMUNITY_Video Call UI|Video Call UI]]
- [[_COMMUNITY_Manual Booking Flow|Manual Booking Flow]]
- [[_COMMUNITY_Doctor Dashboard|Doctor Dashboard]]
- [[_COMMUNITY_Queue Management|Queue Management]]
- [[_COMMUNITY_AI Assistant UI|AI Assistant UI]]
- [[_COMMUNITY_Doctor Earnings|Doctor Earnings]]
- [[_COMMUNITY_Splash & Role Selection|Splash & Role Selection]]
- [[_COMMUNITY_Module 20|Module 20]]
- [[_COMMUNITY_Module 21|Module 21]]
- [[_COMMUNITY_Module 22|Module 22]]
- [[_COMMUNITY_Module 23|Module 23]]
- [[_COMMUNITY_Module 24|Module 24]]
- [[_COMMUNITY_Module 25|Module 25]]
- [[_COMMUNITY_Module 26|Module 26]]
- [[_COMMUNITY_Module 27|Module 27]]
- [[_COMMUNITY_Module 28|Module 28]]
- [[_COMMUNITY_Module 29|Module 29]]
- [[_COMMUNITY_Module 30|Module 30]]
- [[_COMMUNITY_Module 31|Module 31]]
- [[_COMMUNITY_Module 32|Module 32]]
- [[_COMMUNITY_Module 33|Module 33]]
- [[_COMMUNITY_Module 34|Module 34]]
- [[_COMMUNITY_Module 35|Module 35]]
- [[_COMMUNITY_Module 36|Module 36]]
- [[_COMMUNITY_Module 37|Module 37]]
- [[_COMMUNITY_Module 38|Module 38]]
- [[_COMMUNITY_Module 39|Module 39]]
- [[_COMMUNITY_Module 40|Module 40]]
- [[_COMMUNITY_Module 41|Module 41]]
- [[_COMMUNITY_Module 42|Module 42]]
- [[_COMMUNITY_Module 43|Module 43]]
- [[_COMMUNITY_Module 44|Module 44]]
- [[_COMMUNITY_Module 45|Module 45]]
- [[_COMMUNITY_Module 46|Module 46]]
- [[_COMMUNITY_Module 47|Module 47]]
- [[_COMMUNITY_Module 48|Module 48]]
- [[_COMMUNITY_Module 49|Module 49]]
- [[_COMMUNITY_Module 50|Module 50]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 42 edges
2. `../../core/theme/app_colors.dart` - 35 edges
3. `Doclink App` - 34 edges
4. `../../../../core/theme/app_spacing.dart` - 19 edges
5. `package:go_router/go_router.dart` - 15 edges
6. `../../../../shared/widgets/dl_card.dart` - 13 edges
7. `../../../../core/mock/mock_data.dart` - 13 edges
8. `package:flutter_riverpod/flutter_riverpod.dart` - 10 edges
9. `dart:async` - 6 edges
10. `AppDelegate` - 5 edges

## Surprising Connections (you probably didn't know these)
- `Doclink README` --references--> `Doclink App`  [INFERRED]
  README.md → pubspec.yaml
- `Analysis Options Config` --references--> `flutter_lints`  [EXTRACTED]
  analysis_options.yaml → pubspec.yaml
- `index.html Flutter Web Entry` --rationale_for--> `SPA Routing on GitHub Pages`  [INFERRED]
  web/index.html → web/404.html
- `404.html SPA Redirect` --references--> `index.html Flutter Web Entry`  [EXTRACTED]
  web/404.html → web/index.html

## Hyperedges (group relationships)
- **Riverpod State Management Ecosystem** — pubspec_flutter_riverpod, pubspec_riverpod_annotation, pubspec_hooks_riverpod, pubspec_flutter_hooks [INFERRED 0.95]
- **Firebase Backend Suite** — pubspec_firebase_core, pubspec_firebase_messaging, pubspec_firebase_analytics [INFERRED 0.95]
- **Media Handling Capabilities** — pubspec_image_picker, pubspec_file_picker, pubspec_pdf, pubspec_printing, pubspec_cached_network_image [INFERRED 0.85]
- **Local Storage Layer** — pubspec_flutter_secure_storage, pubspec_shared_preferences, pubspec_flutter_dotenv [INFERRED 0.85]
- **QR Code Feature** — pubspec_qr_flutter, pubspec_mobile_scanner [INFERRED 0.95]
- **SPA GitHub Pages Routing Trick** — web_404html, web_indexhtml, rationale_spa_github_pages [EXTRACTED 1.00]

## Communities (56 total, 11 thin omitted)

### Community 0 - "Dependencies & Config"
Cohesion: 0.06
Nodes (39): Analysis Options Config, cached_network_image, connectivity_plus, dartz, dio, Doclink App, equatable, file_picker (+31 more)

### Community 1 - "Auth Data Layer"
Cohesion: 0.07
Nodes (26): AppAuthException, AuthRemoteDataSourceImpl, ServerException, _parseRole, toEntity, UserModel, AuthRepositoryImpl, Left (+18 more)

### Community 2 - "App Entry & Routing"
Cohesion: 0.07
Nodes (23): app.dart, build, DocLinkApp, GoRouter, SecureStorageService, main, ../constants/api_constants.dart, core/router/app_router.dart (+15 more)

### Community 3 - "Chat Consultation UI"
Cohesion: 0.07
Nodes (27): _AttachBtn, build, _ChatBubble, ChatConsultationScreen, _ChatConsultationScreenState, Column, dispose, IconButton (+19 more)

### Community 4 - "Patient Appointments UI"
Cohesion: 0.07
Nodes (27): _AppointmentCard, _AppointmentList, build, Center, dispose, DlCard, Icon, initState (+19 more)

### Community 5 - "Appointment Booking Flow"
Cohesion: 0.07
Nodes (26): BookAppointmentScreen, _BookAppointmentScreenState, build, _buildStep, Center, Color, Column, _ConfirmStep (+18 more)

### Community 6 - "Theme & Auth Screens"
Cohesion: 0.08
Nodes (23): app_colors.dart, AppTheme, build, dispose, initState, OtpScreen, _OtpScreenState, _routeByRole (+15 more)

### Community 7 - "Onboarding Flow"
Cohesion: 0.08
Nodes (24): build, dispose, _next, _OnboardingPage, OnboardingScreen, _OnboardingScreenState, Padding, _PageContent (+16 more)

### Community 8 - "Family Profiles UI"
Cohesion: 0.08
Nodes (25): _ActionButton, _ActionsCard, build, _ConditionsCard, Container, _Divider, DlCard, Expanded (+17 more)

### Community 9 - "Patient Home Dashboard"
Cohesion: 0.08
Nodes (24): _ActionBtn, AppCard, build, Container, _EmptyCard, Expanded, _FamilyChip, Function (+16 more)

### Community 10 - "Patient Records UI"
Cohesion: 0.08
Nodes (24): build, Column, Container, dispose, Divider, DlCard, Icon, initState (+16 more)

### Community 11 - "Receptionist Reminders"
Cohesion: 0.08
Nodes (23): build, Center, Column, dispose, DlCard, Function, Icon, initState (+15 more)

### Community 12 - "Prescription Writer"
Cohesion: 0.09
Nodes (22): _addMedicine, build, Column, Container, copyWith, dispose, Divider, _DropdownField (+14 more)

### Community 13 - "Video Call UI"
Cohesion: 0.09
Nodes (21): Align, build, _ChatPanel, Container, _ControlBtn, dispose, _endCall, Expanded (+13 more)

### Community 14 - "Manual Booking Flow"
Cohesion: 0.1
Nodes (20): build, _buildConfirmStep, _buildPatientStep, _buildSlotStep, _buildTypeStep, Column, _confirmBooking, _ConfirmRow (+12 more)

### Community 15 - "Doctor Dashboard"
Cohesion: 0.11
Nodes (18): _ActionBtn, build, Container, DoctorDashboardScreen, _EarningsCard, Expanded, Function, GestureDetector (+10 more)

### Community 16 - "Queue Management"
Cohesion: 0.11
Nodes (18): build, _callNext, Container, copyWith, dispose, initState, Opacity, QueueBoardScreen (+10 more)

### Community 17 - "AI Assistant UI"
Cohesion: 0.11
Nodes (17): AiAssistantScreen, _AiAssistantScreenState, _AiMessage, build, Column, dispose, _Dot, _DotState (+9 more)

### Community 18 - "Doctor Earnings"
Cohesion: 0.12
Nodes (16): BarChartGroupData, _BreakdownRow, build, Divider, EarningsScreen, _EarningsScreenState, ListTile, Padding (+8 more)

### Community 19 - "Splash & Role Selection"
Cohesion: 0.12
Nodes (15): build, dispose, _enterAs, Function, GestureDetector, initState, Padding, _RoleCard (+7 more)

### Community 20 - "Module 20"
Cohesion: 0.13
Nodes (14): ../../../ai/presentation/screens/ai_assistant_screen.dart, AiAssistantScreen, build, DoctorProfileScreen, DoctorShellScreen, _DoctorShellScreenState, EarningsScreen, _navigate (+6 more)

### Community 21 - "Module 21"
Cohesion: 0.13
Nodes (14): build, _confirmCancel, dispose, Expanded, initState, ListTile, Row, Scaffold (+6 more)

### Community 22 - "Module 22"
Cohesion: 0.13
Nodes (14): build, _confirmDeleteSlot, Divider, Expanded, GestureDetector, Icon, Scaffold, ScheduleScreen (+6 more)

### Community 23 - "Module 23"
Cohesion: 0.13
Nodes (14): build, CircleAvatar, Color, Divider, DlCard, Expanded, _HealthItem, PatientProfileScreen (+6 more)

### Community 24 - "Module 24"
Cohesion: 0.13
Nodes (14): build, FamilyProfilesScreen, _navigate, PatientAppointmentsScreen, PatientProfileScreen, PatientRecordsScreen, PatientShellScreen, _PatientShellScreenState (+6 more)

### Community 25 - "Module 25"
Cohesion: 0.18
Nodes (10): DemoModeNotifier, MockAppointment, MockChatMessage, MockData, MockDoctor, MockEarningEntry, MockMedicine, MockPatient (+2 more)

### Community 26 - "Module 26"
Cohesion: 0.18
Nodes (10): AppDateUtils, formatDate, formatDay, formatMonthYear, formatShort, formatTime, isSameDay, isToday (+2 more)

### Community 27 - "Module 27"
Cohesion: 0.18
Nodes (9): AuthFailure, CacheFailure, Failure, NetworkFailure, NotFoundFailure, ServerFailure, ValidationFailure, UserEntity (+1 more)

### Community 28 - "Module 28"
Cohesion: 0.2
Nodes (9): build, _navigate, ReceptionistShellScreen, _ReceptionistShellScreenState, Scaffold, TextStyle, manual_booking_screen.dart, queue_board_screen.dart (+1 more)

### Community 29 - "Module 29"
Cohesion: 0.22
Nodes (7): build, DlButton, SizedBox, build, Container, DlCard, ../../core/theme/app_colors.dart

### Community 30 - "Module 30"
Cohesion: 0.29
Nodes (6): build, Container, DlSkeleton, DlSkeletonCard, SizedBox, package:shimmer/shimmer.dart

### Community 31 - "Module 31"
Cohesion: 0.33
Nodes (3): FlutterAppDelegate, FlutterImplicitEngineDelegate, AppDelegate

### Community 32 - "Module 32"
Cohesion: 0.33
Nodes (4): AppColors, AppTypography, package:flutter/material.dart, package:google_fonts/google_fonts.dart

### Community 33 - "Module 33"
Cohesion: 0.4
Nodes (4): AppAuthException, CacheException, NetworkException, ServerException

### Community 34 - "Module 34"
Cohesion: 0.4
Nodes (4): build, Center, DlEmptyState, SizedBox

### Community 35 - "Module 35"
Cohesion: 0.4
Nodes (4): build, DoctorShell, Scaffold, package:go_router/go_router.dart

### Community 36 - "Module 36"
Cohesion: 0.4
Nodes (4): build, _currentIndex, PatientShell, Scaffold

### Community 37 - "Module 37"
Cohesion: 0.4
Nodes (4): AppCard, build, Container, GradientCard

### Community 38 - "Module 38"
Cohesion: 0.4
Nodes (4): build, _currentIndex, ReceptionistShell, Scaffold

### Community 46 - "Module 46"
Cohesion: 1.0
Nodes (3): SPA Routing on GitHub Pages, 404.html SPA Redirect, index.html Flutter Web Entry

## Knowledge Gaps
- **587 isolated node(s):** `MainActivity`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `-registerWithRegistry`, `DocLinkApp`, `build` (+582 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **11 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Module 32` to `App Entry & Routing`, `Chat Consultation UI`, `Patient Appointments UI`, `Appointment Booking Flow`, `Theme & Auth Screens`, `Onboarding Flow`, `Family Profiles UI`, `Patient Home Dashboard`, `Patient Records UI`, `Receptionist Reminders`, `Prescription Writer`, `Video Call UI`, `Manual Booking Flow`, `Doctor Dashboard`, `Queue Management`, `AI Assistant UI`, `Doctor Earnings`, `Splash & Role Selection`, `Module 20`, `Module 21`, `Module 22`, `Module 23`, `Module 24`, `Module 25`, `Module 28`, `Module 29`, `Module 30`, `Module 34`, `Module 35`, `Module 36`, `Module 37`, `Module 38`?**
  _High betweenness centrality (0.295) - this node is a cross-community bridge._
- **Why does `../../core/theme/app_colors.dart` connect `Module 29` to `Chat Consultation UI`, `Patient Appointments UI`, `Appointment Booking Flow`, `Theme & Auth Screens`, `Onboarding Flow`, `Family Profiles UI`, `Patient Home Dashboard`, `Patient Records UI`, `Receptionist Reminders`, `Prescription Writer`, `Video Call UI`, `Manual Booking Flow`, `Doctor Dashboard`, `Queue Management`, `AI Assistant UI`, `Doctor Earnings`, `Splash & Role Selection`, `Module 20`, `Module 21`, `Module 22`, `Module 23`, `Module 24`, `Module 28`, `Module 30`, `Module 34`, `Module 35`, `Module 36`, `Module 37`, `Module 38`?**
  _High betweenness centrality (0.205) - this node is a cross-community bridge._
- **Why does `../../../../core/theme/app_spacing.dart` connect `Onboarding Flow` to `Chat Consultation UI`, `Patient Appointments UI`, `Appointment Booking Flow`, `Theme & Auth Screens`, `Family Profiles UI`, `Patient Records UI`, `Receptionist Reminders`, `Prescription Writer`, `Video Call UI`, `Manual Booking Flow`, `Queue Management`, `AI Assistant UI`, `Doctor Earnings`, `Module 22`, `Module 23`?**
  _High betweenness centrality (0.073) - this node is a cross-community bridge._
- **What connects `MainActivity`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `-registerWithRegistry` to the rest of the system?**
  _587 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Dependencies & Config` be split into smaller, more focused modules?**
  _Cohesion score 0.06 - nodes in this community are weakly interconnected._
- **Should `Auth Data Layer` be split into smaller, more focused modules?**
  _Cohesion score 0.07 - nodes in this community are weakly interconnected._
- **Should `App Entry & Routing` be split into smaller, more focused modules?**
  _Cohesion score 0.07 - nodes in this community are weakly interconnected._