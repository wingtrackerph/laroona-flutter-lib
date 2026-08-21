import 'package:flutter/material.dart';
import 'package:laroona_flutter_lib/resources/dimensions.dart';
import 'package:laroona_flutter_lib/utils/theme_helper.dart';

enum AppChipSize { small, defaultSize }

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.isSolid = false,
    this.hasBorder = false,
    this.size = AppChipSize.defaultSize,
    this.backgroundColor,
    this.textColor,
  });

  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSolid;
  final bool hasBorder;
  final AppChipSize size;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? ThemeColors.getPrimaryColor(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size == AppChipSize.small
            ? paddingSizeXXXSmall
            : paddingSizeXXSmall,
        vertical: size == AppChipSize.small
            ? paddingSizeXXXXSmall
            : paddingSizeXXXSmall,
      ),
      decoration: BoxDecoration(
        color:
            backgroundColor ?? (isSolid ? color : color.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(
          size == AppChipSize.small ? radiusSizeSmall : radiusSize,
        ),
        border: hasBorder
            ? Border.all(color: color.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon!,
              size: 12,
              color: textColor ?? (isSolid ? Colors.white : color),
            ),
            SizedBox(
              width: size == AppChipSize.small
                  ? paddingSizeXXXSmall
                  : paddingSizeXXSmall,
            ),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: size == AppChipSize.small ? 11 : 12,
              fontWeight: FontWeight.bold,
              color: textColor ?? (isSolid ? Colors.white : color),
            ),
          ),
        ],
      ),
    );
  }
}
