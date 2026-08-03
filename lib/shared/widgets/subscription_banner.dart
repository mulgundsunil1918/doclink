import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';

/// Surfaces the doctor's subscription state above their workspace.
///
/// A lapsed subscription puts the account in read-only mode: every existing
/// patient, record and prescription stays readable, but new bookings and new
/// prescriptions are refused. The real enforcement is RLS (migration 007) —
/// this banner exists so the doctor understands why, instead of hitting an
/// unexplained failure mid-consultation.
class SubscriptionBanner extends ConsumerWidget {
  const SubscriptionBanner({super.key});

  /// Start nudging this many days before expiry.
  static const _warnWithinDays = 7;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doc = ref.watch(currentDoctorProvider).valueOrNull;
    if (doc == null) return const SizedBox.shrink();

    if (!doc.subscriptionActive) {
      return _Bar(
        background: const Color(0xFFFEE2E2),
        foreground: const Color(0xFF991B1B),
        icon: Icons.lock_outline_rounded,
        title: 'Subscription expired — read-only mode',
        detail: 'Your records are safe and still readable. Renew to take new '
            'bookings and write prescriptions again.',
        onRenew: () => _showRenew(context, doc),
      );
    }

    final left = doc.daysLeft;
    if (left != null && left <= _warnWithinDays) {
      return _Bar(
        background: const Color(0xFFFEF3C7),
        foreground: const Color(0xFF92400E),
        icon: Icons.schedule_rounded,
        title: left <= 0
            ? 'Subscription expires today'
            : 'Subscription ends in $left day${left == 1 ? '' : 's'}',
        detail: 'Renew to keep taking new bookings without interruption.',
        onRenew: () => _showRenew(context, doc),
      );
    }

    return const SizedBox.shrink();
  }

  void _showRenew(BuildContext context, AppDoctor doc) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Renew your Doclink plan',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Doclink charges a flat subscription and takes no share of your '
              'consultation fees — patients already pay you directly.',
              style: TextStyle(color: AppColors.slate500, height: 1.5),
            ),
            const SizedBox(height: 16),
            Text('Current plan: ${doc.plan}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            const Text(
              'In-app renewal is not live yet. Contact Doclink support to '
              'reactivate your account.',
              style: TextStyle(color: AppColors.slate400, fontSize: 12),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final Color background, foreground;
  final IconData icon;
  final String title, detail;
  final VoidCallback onRenew;

  const _Bar({
    required this.background,
    required this.foreground,
    required this.icon,
    required this.title,
    required this.detail,
    required this.onRenew,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: foreground)),
                    Text(detail,
                        style: TextStyle(
                            fontSize: 11,
                            height: 1.35,
                            color: foreground.withValues(alpha: 0.85))),
                  ],
                ),
              ),
              TextButton(
                onPressed: onRenew,
                style: TextButton.styleFrom(foregroundColor: foreground),
                child: const Text('Renew'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
