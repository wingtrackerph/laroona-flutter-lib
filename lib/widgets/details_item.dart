import 'package:flutter/material.dart';
import 'package:laroona_flutter_lib/resources/colors.dart';
import 'package:laroona_flutter_lib/resources/dimensions.dart';
import 'package:laroona_flutter_lib/utils/theme_helper.dart';
import 'package:laroona_flutter_lib/widgets/icon_card.dart';

class DetailsItem extends StatelessWidget {
  const DetailsItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isClickable = false,
    this.hasBottomMargin = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isClickable;
  final bool hasBottomMargin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: hasBottomMargin ? paddingSizeXXXSmall : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconCard(
            icon: icon,
            size: IconCardSize.small,
            color: ThemeColors.getTextColor(context),
          ),
          const SizedBox(width: paddingSizeXXSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ThemeColors.getGrayTextColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              valueColor ?? ThemeColors.getTextColor(context),
                        ),
                      ),
                    ),
                    if (isClickable) ...[
                      const SizedBox(width: paddingSizeXXSmall),
                      Icon(
                        Icons.open_in_new,
                        size: iconSizeSmall,
                        color: primaryColor,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
