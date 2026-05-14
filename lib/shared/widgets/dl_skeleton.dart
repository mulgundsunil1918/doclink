import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

class DlSkeleton extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const DlSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.slate800,
      highlightColor: AppColors.slate700,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.slate800,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class DlSkeletonCard extends StatelessWidget {
  const DlSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.doctorCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.doctorBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DlSkeleton(height: 14, width: 120),
          const SizedBox(height: 10),
          const DlSkeleton(height: 12),
          const SizedBox(height: 6),
          DlSkeleton(height: 12, width: MediaQuery.of(context).size.width * 0.5),
        ],
      ),
    );
  }
}
