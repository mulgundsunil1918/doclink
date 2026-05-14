import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class _OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      title: 'Your Digital\nClinic. Owned by You.',
      subtitle:
          'Not a marketplace. Doclink gives every doctor a complete digital practice ecosystem — consultations, prescriptions, earnings.',
      icon: Icons.local_hospital_rounded,
      iconBg: AppColors.doctorPrimary,
    ),
    _OnboardingPage(
      title: 'QR-Native\nPatient Flow.',
      subtitle:
          'Share your QR code — patients scan, book, pay, and join consultations. Zero friction from discovery to diagnosis.',
      icon: Icons.qr_code_rounded,
      iconBg: AppColors.doctorAccent,
    ),
    _OnboardingPage(
      title: 'AI-Assisted.\nDoctor-Decided.',
      subtitle:
          'SOAP notes, prescription drafts, consultation summaries — AI suggests, you approve. India-first, compliance-ready.',
      icon: Icons.psychology_rounded,
      iconBg: Color(0xFF7C3AED),
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.goNamed('login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.doctorSurface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.goNamed('login'),
                child: const Text('Skip',
                    style: TextStyle(color: AppColors.slate400)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _PageContent(page: _pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin:
                            const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.doctorPrimary
                              : AppColors.slate700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ElevatedButton(
                    onPressed: _next,
                    child: Text(_currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;
  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: page.iconBg.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: page.iconBg.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(page.icon, color: page.iconBg, size: 52),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(height: 1.2),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.slate400,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}
