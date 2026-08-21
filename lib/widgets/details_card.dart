import 'package:flutter/material.dart';
import 'package:laroona_flutter_lib/resources/colors.dart';
import 'package:laroona_flutter_lib/resources/dimensions.dart';
import 'package:laroona_flutter_lib/utils/theme_helper.dart';
import 'package:laroona_flutter_lib/widgets/app_card.dart';
import 'package:laroona_flutter_lib/widgets/icon_card.dart';

class DetailsCard extends StatelessWidget {
  const DetailsCard({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    required this.body,
  });

  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final iconColor = this.iconColor ?? primaryColor;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              IconCard(size: IconCardSize.small, icon: icon, color: iconColor),
              const SizedBox(width: paddingSizeXXSmall),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.getTextColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: paddingSizeXXSmall),
          // Content
          body,
        ],
      ),
    );
  }
}
