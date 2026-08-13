import 'package:flutter/material.dart';
import 'package:shop/core/widgets/app_image.dart';
import 'package:shop/core/widgets/custom_text.dart';
import 'package:shop/core/theme/styles.dart';

class CollectionCard extends StatelessWidget {
  final String imageUrl;
  final String overlayText;
  final String subtitle;
  final VoidCallback? onTap;

  const CollectionCard({
    super.key,
    required this.imageUrl,
    required this.overlayText,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1.0, // Fixed aspect ratio
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AppImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Overlay gradient for readability
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withValues(alpha: 0.2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: AppText(
                    overlayText,
                    textAlign: TextAlign.center,
                    alignment: AlignmentDirectional.center,
                    maxLines: 2,
                    style: font22w500.copyWith(
                      color: const Color(0xFFF7DEB1), // Pale cream/yellow
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          offset: const Offset(1, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AppText(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  alignment: AlignmentDirectional.center,
                  style: font14w700.copyWith(color: const Color(0xFF5C2428)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
