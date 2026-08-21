import 'package:flutter/material.dart';
import 'package:laroona_flutter_lib/resources/colors.dart';
import 'package:laroona_flutter_lib/resources/dimensions.dart';
import 'package:laroona_flutter_lib/utils/theme_helper.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: paddingSizeXXSmall),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: iconSizeSmall),
          const SizedBox(width: paddingSizeXXSmall),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeColors.getTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
