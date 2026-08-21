import 'package:flutter/material.dart';
import 'package:laroona_flutter_lib/resources/colors.dart';
import 'package:laroona_flutter_lib/resources/dimensions.dart';
import 'package:laroona_flutter_lib/utils/theme_helper.dart';

enum LoadingButtonStyle { primary, white }

class LoadingButton extends StatefulWidget {
  const LoadingButton({
    super.key,
    required this.text,
    required this.isLoading,
    this.style,
    this.compact = false,
    this.onPressed,
  });

  final String text;
  final bool isLoading;
  final LoadingButtonStyle? style;
  final bool compact;
  final VoidCallback? onPressed;

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  late LoadingButtonStyle _style;

  @override
  void initState() {
    super.initState();

    _style = widget.style ?? LoadingButtonStyle.primary;
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    final compact = widget.compact;

    switch (_style) {
      case LoadingButtonStyle.primary:
        backgroundColor = primaryColor;
        textColor = Colors.white;
        break;
      case LoadingButtonStyle.white:
        backgroundColor = ThemeColors.getCardColor(context);
        textColor = ThemeColors.getTextColor(context);
        break;
    }

    final buttonStyle = compact
        ? ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          );

    return ElevatedButton.icon(
      style: buttonStyle,
      icon: widget.isLoading
          ? Container(
              width: compact ? 12 : iconSize,
              height: compact ? 12 : iconSize,
              padding: const EdgeInsets.all(2.0),
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
          : null,
      onPressed: widget.isLoading ? null : widget.onPressed,
      label: Text(
        widget.text,
        style: TextStyle(color: textColor, fontSize: compact ? 12 : 14),
      ),
    );
  }
}
