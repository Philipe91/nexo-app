import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/tokens.dart';

/// Bloco de placeholder com shimmer. Usar pra esconder loading enquanto
/// dados não chegam — em vez de spinner.
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    super.key,
    this.height = 16,
    this.width,
    this.borderRadius = 8,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = dark ? NexoColors.darkSurfaceMuted : NexoColors.lightSurfaceMuted;
    final highlight = dark ? NexoColors.darkBorder : NexoColors.lightBorder;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 1400),
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Card-skeleton padrão pra listas: ícone + 2 linhas.
class AppListSkeleton extends StatelessWidget {
  const AppListSkeleton({super.key, this.itemCount = 5});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: NexoSpace.md),
          child: Row(
            children: [
              const AppSkeleton(height: 40, width: 40, borderRadius: 10),
              const SizedBox(width: NexoSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    AppSkeleton(height: 14, borderRadius: 4),
                    SizedBox(height: 8),
                    AppSkeleton(height: 12, width: 160, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
