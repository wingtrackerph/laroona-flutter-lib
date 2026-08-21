import 'package:flutter/material.dart';
import 'package:laroona_flutter_lib/resources/dimensions.dart';
import 'package:laroona_flutter_lib/utils/theme_helper.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.color,
    this.isGradient = false,
    this.hasBorder = false,
    this.bottomMargin = 0,
    this.horizontalMargin = 0,
    this.paddingVertical = paddingSizeXSmall,
    this.paddingHorizontal = paddingSizeXSmall,
    this.borderRadius,
    this.borderColor,
  });

  final Widget child;
  final Color? color;
  final bool isGradient;
  final bool hasBorder;
  final double bottomMargin;
  final double horizontalMargin;
  final double paddingVertical;
  final double paddingHorizontal;
  final double? borderRadius;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    // Background color: white in light mode, dark card color in dark mode
    final backgroundColor = ThemeColors.isDark(context)
        ? ThemeColors.getCardColor(context)
        : Colors.white;

    // Card color: use provided color or default to background
    final cardColor = color ?? backgroundColor;

    return Container(
      margin: EdgeInsets.only(
        bottom: bottomMargin,
        left: horizontalMargin,
        right: horizontalMargin,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius ?? cardRadiusSize),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: paddingVertical,
          horizontal: paddingHorizontal,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isGradient ? null : cardColor,
          gradient: isGradient
              ? LinearGradient(
                  colors: [
                    cardColor.withValues(alpha: 0.25),
                    cardColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: hasBorder
              ? Border.all(
                  color: borderColor ?? cardColor.withValues(alpha: 0.2),
                  width: 1,
                )
              : null,
          borderRadius: BorderRadius.circular(borderRadius ?? cardRadiusSize),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.isDark(context)
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
