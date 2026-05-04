import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Avatar circular com fallback de iniciais. Suporta status dot opcional.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.color,
    this.size = 36,
    this.status,
    this.imageUrl,
  });

  final String name;
  final Color? color;
  final double size;
  final Color? status;
  final String? imageUrl;

  String _initial() {
    final t = name.trim();
    if (t.isEmpty) return 'N';
    return t[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? NexoColors.indigo;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              image: hasImage
                  ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
                  : null,
            ),
            alignment: Alignment.center,
            child: hasImage
                ? null
                : Text(
                    _initial(),
                    style: AppTheme.display(
                      size: size * 0.4,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
          if (status != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.30,
                height: size * 0.30,
                decoration: BoxDecoration(
                  color: status,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
