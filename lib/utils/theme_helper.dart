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
