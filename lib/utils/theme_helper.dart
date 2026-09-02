import 'package:flutter/material.dart';
import 'package:laroona_flutter_lib/resources/colors.dart';

/// Helper class to get theme-aware colors
class ThemeColors {
  /// Get background color based on theme
  static Color getBgColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkPrimaryBgColor
        : primaryBgColor;
  }

  /// Get layout background color based on theme
  static Color getLayoutBgColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBgLayoutColor
        : bgLayoutColor;
  }

  /// Get card color based on theme
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCardColor
        : Colors.white;
  }

  /// Get text color based on theme
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkDarkTextColor
        : darkTextColor;
  }

  /// Get gray text color based on theme
  static Color getGrayTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkGrayTextColor
        : grayTextColor;
  }

  /// Get disabled border color based on theme
  static Color getDisabledBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkDisabledBorderColor
        : disabledBorderColor;
  }

  /// Get disabled text color based on theme
  static Color getDisabledTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkDisabledTextColor
        : disabledTextColor;
  }

  /// Get hint text color based on theme
  static Color getHintTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkHintTextColor
        : hintTextColor;
  }

  /// Get stone300 color based on theme
  static Color getStone300Color(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkStone300Color
        : stone300Color;
  }

  /// Get divider color based on theme
  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkDividerColor
        : dividerColor;
  }

  /// Check if current theme is dark
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : primaryColor;
  }
}

/// The brand marks, per theme.
///
/// RECOVERED FROM THE PUB-CACHE, where it had been hand-edited into the
/// downloaded copy of this package and never committed. Consuming apps used it
/// as though it shipped here, so `flutter pub cache clean` -- or a checkout on
/// any other machine -- broke their build with `Undefined name 'ThemeLogos'`.
class ThemeLogos {
  static String getTitleLogo(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? 'assets/images/title_logo_dark.png'
        : 'assets/images/title_logo.png';
  }

  static String getSplashLogo(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? 'assets/images/splash_logo_dark.png'
        : 'assets/images/splash_logo.png';
  }
}
