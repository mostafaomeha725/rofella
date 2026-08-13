import 'package:flutter/material.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? customPadding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1600,
    this.customPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: customPadding ??
              EdgeInsets.symmetric(
                horizontal: _getResponsivePadding(context),
              ),
          child: child,
        ),
      ),
    );
  }

  double _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 1200) return 32.0;
    if (width > 768) return 16.0;
    return 4.0; // Reduced heavily for mobile
  }
}
