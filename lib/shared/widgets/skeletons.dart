import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Loading skeleton for stat cards.
class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: AppColors.skeleton,
        highlightColor: AppColors.skeletonHighlight,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.skeleton,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                ),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.skeleton,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 32,
                  color: AppColors.skeleton,
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Container(
                  width: 120,
                  height: 16,
                  color: AppColors.skeleton,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading skeleton for list items.
class ListItemSkeleton extends StatelessWidget {
  final int count;

  const ListItemSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: AppColors.skeleton,
        highlightColor: AppColors.skeletonHighlight,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppConstants.spacingSm),
        itemBuilder: (_, __) => _buildListItem(),
      ),
    );
  }

  Widget _buildListItem() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.skeleton,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 14,
                  color: AppColors.skeleton,
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Container(
                  width: 100,
                  height: 12,
                  color: AppColors.skeleton,
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.skeleton,
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading skeleton for tables.
class TableSkeleton extends StatelessWidget {
  final int rows;
  final int columns;

  const TableSkeleton({
    super.key,
    this.rows = 5,
    this.columns = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: AppColors.skeleton,
        highlightColor: AppColors.skeletonHighlight,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Row(
              children: List.generate(
                columns,
                (index) => Expanded(
                  child: Container(
                    height: 16,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingXs,
                    ),
                    color: AppColors.skeleton,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          // Rows
          ...List.generate(
            rows,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
                vertical: AppConstants.spacingMd,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Row(
                children: List.generate(
                  columns,
                  (colIndex) => Expanded(
                    child: Container(
                      height: 14,
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingXs,
                      ),
                      color: AppColors.skeleton,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
