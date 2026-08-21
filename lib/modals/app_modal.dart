import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laroona_flutter_lib/resources/dimensions.dart';
import 'package:laroona_flutter_lib/utils/theme_helper.dart';

class AppModal extends StatelessWidget {
  const AppModal({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: paddingSizeXSmall,
        vertical: paddingSizeXXSmall,
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: kIsWeb ? 1200 : double.infinity,
        ),
        decoration: BoxDecoration(
          color: ThemeColors.getCardColor(context),
          borderRadius: BorderRadius.circular(radiusSize),
        ),
        child: child,
      ),
    );
  }
}
