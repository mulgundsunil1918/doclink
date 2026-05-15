import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;
  final double radius;
  final bool dark;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
    this.radius = 16,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? (dark ? AppColors.darkCard : AppColors.surface);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: dark
            ? const []
            : [
                BoxShadow(
                  color: Color(0x0F1E293B),
                  blurRadius: 20,
                  spreadRadius: -2,
                  offset: Offset(0, 4),
                ),
                BoxShadow(
                  color: Color(0x0A1E293B),
                  blurRadius: 6,
                  spreadRadius: -4,
                  offset: Offset(0, 1),
                ),
              ],
        border: dark
            ? Border.all(color: AppColors.darkBorder, width: 0.5)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// Gradient header card for hero sections
class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final EdgeInsetsGeometry? padding;
  final double radius;

  const GradientCard({
    super.key,
    required this.child,
    this.colors = const [AppColors.primaryDeep, AppColors.primary],
    this.padding,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
