import 'package:flutter/material.dart';
import 'package:laroona_flutter_lib/resources/dimensions.dart';
import 'package:laroona_flutter_lib/utils/theme_helper.dart';

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.enabled = true,
    required this.decoration,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final InputDecoration decoration;
  final bool enabled;
  final Function(String)? onChanged;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      obscureText: !_isPasswordVisible,
      textInputAction: TextInputAction.next,
      enabled: widget.enabled,
      style: TextStyle(
        color: ThemeColors.getTextColor(context),
        fontSize: inputFontSize,
      ),
      decoration: widget.decoration.copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: ThemeColors.getGrayTextColor(context),
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
