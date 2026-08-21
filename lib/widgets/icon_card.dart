import 'package:flutter/material.dart';
import 'package:laroona_flutter_lib/resources/colors.dart';
import 'package:laroona_flutter_lib/resources/dimensions.dart';
import 'package:laroona_flutter_lib/utils/theme_helper.dart';

enum IconCardSize { xSmall, small, defaultSize, large }

class IconCard extends StatelessWidget {
  const IconCard({
    super.key,
    this.icon,
    this.assetPath,
    this.fallbackAssetPath,
    this.size = IconCardSize.defaultSize,
    this.color,
    this.backgroundColor,
    this.borderRadius = 10.0,
    this.assetHasColor = true,
  }) : assert(
         icon != null || assetPath != null,
         'Either icon or assetPath must be provided',
       );

  final IconData? icon;
  final String? assetPath;
  final String? fallbackAssetPath;
  final IconCardSize size;
  final Color? color;
  final Color? backgroundColor;
  final double borderRadius;
  final bool assetHasColor;

  double get _containerSize {
    switch (size) {
      case IconCardSize.xSmall:
        return 26.0;
      case IconCardSize.small:
        return 32.0;
      case IconCardSize.defaultSize:
        return 40.0;
      case IconCardSize.large:
        return 48.0;
    }
  }

  double get _iconSize {
    switch (size) {
      case IconCardSize.xSmall:
        return iconSizeSmall;
      case IconCardSize.small:
        return iconSizeSmall;
      case IconCardSize.defaultSize:
        return iconSize;
      case IconCardSize.large:
        return iconSizeLarge;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        width: _containerSize,
        height: _containerSize,
        decoration: BoxDecoration(
          color:
              backgroundColor ??
              ((ThemeColors.isDark(context) && color == primaryColor)
                  ? Colors.transparent
                  : color.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: assetPath != null
              ? Image.asset(
                  assetPath!,
                  width: _iconSize,
                  height: _iconSize,
                  color: assetHasColor ? color : null,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to icon if asset fails to load
                    return fallbackAssetPath != null
                        ? Image.asset(
                            fallbackAssetPath!,
                            width: _iconSize,
                            height: _iconSize,
                            color: assetHasColor ? color : null,
                          )
                        : Icon(
                            icon ?? Icons.error,
                            size: _iconSize,
                            color: color,
                          );
                  },
                )
              : Icon(icon!, size: _iconSize, color: color),
        ),
      ),
    );
  }
}
