import 'package:flutter/material.dart';

const defaultPrimaryColor = Color(0xff52c41a);
Color? themeColor;

void setThemeColor(String? color) {
  if (color == null || color.isEmpty) {
    themeColor = null;
    return;
  }

  themeColor = Color(int.parse(color.substring(1), radix: 16) + 0xFF000000);
}

Color get primaryColor => themeColor ?? defaultPrimaryColor;

// Light Theme Colors - Background
const defaultPrimaryBgColor = Color(0xfff6ffed);
const defaultBgLayoutColor = Color(0xfff5f5f4);
Color? customPrimaryBgColor;
Color? customBgLayoutColor;

void setPrimaryBgColor(String? color) {
  if (color == null || color.isEmpty) {
    customPrimaryBgColor = null;
    return;
  }
  customPrimaryBgColor = Color(
    int.parse(color.substring(1), radix: 16) + 0xFF000000,
  );
}

void setBgLayoutColor(String? color) {
  if (color == null || color.isEmpty) {
    customBgLayoutColor = null;
    return;
  }
  customBgLayoutColor = Color(
    int.parse(color.substring(1), radix: 16) + 0xFF000000,
  );
}

Color get primaryBgColor => customPrimaryBgColor ?? defaultPrimaryBgColor;
Color get bgLayoutColor => customBgLayoutColor ?? defaultBgLayoutColor;

// Light Theme Colors - Other
const darkTextColor = Color(0xff30455e);
const grayTextColor = Color(0xff898989);
const disabledBorderColor = Color(0xffe0dddd);
const disabledTextColor = Color(0xffb6b5bc);
const hintTextColor = Color.fromARGB(255, 145, 153, 165);
const stone300Color = Color.fromARGB(255, 214, 211, 209);
const dividerColor = Color(0xffd3d3d3);

// Dark Theme Colors - Background
const defaultDarkPrimaryBgColor = Color(0xff0f1419);
const defaultDarkBgLayoutColor = Color(0xff1a1f26);
Color? customDarkPrimaryBgColor;
Color? customDarkBgLayoutColor;

void setDarkPrimaryBgColor(String? color) {
  if (color == null || color.isEmpty) {
    customDarkPrimaryBgColor = null;
    return;
  }
  customDarkPrimaryBgColor = Color(
    int.parse(color.substring(1), radix: 16) + 0xFF000000,
  );
}

void setDarkBgLayoutColor(String? color) {
  if (color == null || color.isEmpty) {
    customDarkBgLayoutColor = null;
    return;
  }
  customDarkBgLayoutColor = Color(
    int.parse(color.substring(1), radix: 16) + 0xFF000000,
  );
}

Color get darkPrimaryBgColor =>
    customDarkPrimaryBgColor ?? defaultDarkPrimaryBgColor;
Color get darkBgLayoutColor =>
    customDarkBgLayoutColor ?? defaultDarkBgLayoutColor;

// Dark Theme Colors - Other
const darkCardColor = Color(0xff1e2329);
const darkDarkTextColor = Color(0xffe3e8ef);
const darkGrayTextColor = Color(0xffd5dce3);
const darkDisabledBorderColor = Color(0xff2d3339);
const darkDisabledTextColor = Color(0xff6b7280);
const darkHintTextColor = Color(0xff8b95a1);
const darkStone300Color = Color(0xff374151);
const darkDividerColor = Color(0xff2d3339);
