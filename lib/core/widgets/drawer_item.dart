import 'package:flutter/material.dart';
import 'package:shop/core/widgets/app_image.dart';

class DrawerItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final IconData? leadingIcon;
  final String? imageUrl;
  final bool isSelected;
  final bool hasTrailing;

  const DrawerItem({
    super.key,
    required this.title,
    required this.onTap,
    this.leadingIcon,
    this.imageUrl,
    this.isSelected = false,
    this.hasTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFC76962); // Maroon active
    const inactiveColor = Color(0xFF7A4543); // Maroon inactive
    const selectedBgColor = Color(0xFFF6DFD4); // Soft peach

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            decoration: BoxDecoration(
              color: isSelected ? selectedBgColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: AppImage(
                      imageUrl: imageUrl!,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                ] else if (leadingIcon != null) ...[
                  Icon(
                    leadingIcon,
                    color: activeColor,
                    size: 22,
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: inactiveColor,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected || hasTrailing)
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: activeColor,
                    size: 14,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
