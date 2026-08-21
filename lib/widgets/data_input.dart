import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laroona_flutter_lib/providers/request_provider.dart';
import 'package:laroona_flutter_lib/resources/dimensions.dart';
import 'package:laroona_flutter_lib/utils/date_helper.dart';
import 'package:laroona_flutter_lib/utils/theme_helper.dart';
import 'package:laroona_flutter_lib/widgets/dropdown.dart';
import 'package:laroona_flutter_lib/widgets/password_text_field.dart';
import 'package:provider/provider.dart';

enum DataInputType {
  input,
  password,
  date,
  time,
  number,
  textArea,
  select,
  multiSelect,
}

class DataInput extends StatefulWidget {
  const DataInput({
    super.key,
    required this.requestKey,
    required this.type,
    required this.title,
    required this.dataKey,
    this.errorKey,
    this.placeholder,
    this.disabled = false,
    this.hidden = false,
    this.icon,
    this.hasShowPassword = false,
    this.isLast = false,
    this.options,
    this.optionsKey,
    this.isInitialValueDisabled = false,
    this.disabledValues,
    this.allCaps = false,
    this.capitalize = false,
    this.capitalizeFirst = false,
    this.maxLength,
    this.onSetValue,
    this.autoFocus = false,
    this.isRequired = false,
    this.requiredLength,
    this.wholeNumbersOnly = false,
    this.prefixText,
  });

  final String requestKey;
  final DataInputType type;
  final String title;
  final String dataKey;
  final String? errorKey;
  final String? placeholder;
  final bool disabled;
  final bool hidden;
  final Widget? icon;
  final bool hasShowPassword;
  final bool isLast;
  final List? options;
  final String? optionsKey;
  final bool isInitialValueDisabled;
  final List? disabledValues;
  final bool allCaps;
  final bool capitalize;
  final bool capitalizeFirst;
  final int? maxLength;
  final Function(dynamic value)? onSetValue;
  final bool autoFocus;
  final bool isRequired;
  final int? requiredLength;
  final bool wholeNumbersOnly;
  final String? prefixText;

  @override
  State<DataInput> createState() => _DataInputState();
}

class _DataInputState extends State<DataInput> {
  final _controller = TextEditingController();
  bool _addedValidation = false;
  late final RequestProvider _requestProvider;

  @override
  void initState() {
    super.initState();
    _requestProvider = Provider.of<RequestProvider>(context, listen: false);

    if (widget.isRequired ||
        widget.requiredLength != null ||
        widget.type == DataInputType.date ||
        widget.type == DataInputType.time) {
      var validations = _requestProvider
          .getPostRequest(widget.requestKey)
          .validations;
      if (!validations.any(
        (validation) => validation.dataKey == widget.dataKey,
      )) {
        validations.add(
          PostDataValidation(
            dataKey: widget.dataKey,
            errorKey: widget.errorKey,
            isRequired: widget.isRequired,
            requiredLength: widget.requiredLength,
            isDate: widget.type == DataInputType.date,
            isTime: widget.type == DataInputType.time,
          ),
        );
        _addedValidation = true;
      }
    }
  }

  @override
  void dispose() {
    if (_addedValidation) {
      _requestProvider
          .getPostRequest(widget.requestKey)
          .validations
          .removeWhere((validation) => validation.dataKey == widget.dataKey);
    }
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(
    dynamic value,
    RequestProvider requestProvider,
    dynamic data,
  ) {
    requestProvider.clearPostRequestErrorProperty(
      widget.requestKey,
      widget.dataKey,
    );
    data[widget.dataKey] = value;
    if (widget.onSetValue != null) {
      widget.onSetValue!(value);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    RequestProvider requestProvider = Provider.of<RequestProvider>(
      context,
      listen: true,
    );
    final postRequest = requestProvider.getPostRequest(widget.requestKey);
    final data = postRequest.postData;
    var error = requestProvider.getPostRequestErrorProperty(
      widget.requestKey,
      widget.errorKey ?? widget.dataKey,
    );
    if (error != null) {
      error = error.replaceAll(' id ', ' ');
    }

    dynamic value = (data.containsKey(widget.dataKey)
        ? data[widget.dataKey] ?? ''
        : '');
    if (widget.type == DataInputType.date) {
      if (isValidDate(value, '-')) {
        value = convertSqlDateToUiDate(value);
      }
    } else if (widget.type == DataInputType.time) {
      if (isValidTime(value)) {
        value = convertSqlDateToUiTime(value);
      }
    } else if ((widget.type == DataInputType.select ||
            widget.type == DataInputType.multiSelect) &&
        widget.disabled) {
      var values = <dynamic>[];
      if (value != null) {
        if (value is List) {
          values = value;
        } else if ((value is String && value.isNotEmpty) || value is! String) {
          values = [value];
        }
      }
      final selectedValues = <String>[];
      for (var value in values) {
        for (var option in widget.options!) {
          final stringOption = option[widget.optionsKey];
          if (value.toString() == option['id'].toString()) {
            selectedValues.add(stringOption);
            break;
          }
        }
      }

      if (selectedValues.isNotEmpty) {
        value = selectedValues.join(', ');
      }
    } else if (widget.type == DataInputType.number &&
        (value is int || value is double)) {
      value = value.toString();
    }

    var inputValue = value == null
        ? ''
        : (value is String ? value : value.toString());
    if (widget.type == DataInputType.number &&
        widget.prefixText != null &&
        widget.prefixText!.isNotEmpty &&
        inputValue.startsWith(widget.prefixText!)) {
      inputValue = inputValue.substring(widget.prefixText!.length);
    }

    if (inputValue != _controller.text) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) {
          return;
        }
        _controller.text = inputValue;
      });
    }

    final showPassword =
        widget.type == DataInputType.password && widget.hasShowPassword;
    final icon = showPassword
        ? Icon(Icons.lock, color: ThemeColors.getGrayTextColor(context))
        : widget.icon;

    final hintText = widget.type == DataInputType.date
        ? 'mm/dd/yyyy'
        : widget.placeholder;

    final decoration = InputDecoration(
      prefixIcon: widget.prefixText != null && icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: paddingSizeXXSmall),
                icon,
                Text(
                  widget.prefixText!,
                  style: TextStyle(
                    color: ThemeColors.getTextColor(context),
                    fontSize: inputFontSize,
                  ),
                ),
              ],
            )
          : (widget.prefixText == null ? icon : null),
      prefixText: widget.prefixText != null && icon == null
          ? widget.prefixText
          : null,
      hintText: hintText,
      labelText: widget.title,
      fillColor: ThemeColors.getCardColor(context),
      counterText: "",
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ThemeColors.getDisabledBorderColor(context),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      errorText: error,
      suffixIcon: widget.type == DataInputType.select && widget.disabled
          ? const Icon(Icons.arrow_drop_down)
          : null,
    );

    if (widget.type == DataInputType.password && widget.hasShowPassword) {
      // There's a bug on stateful Textfield, next button not working
      return PasswordTextField(
        controller: _controller,
        decoration: decoration,
        enabled: !widget.disabled,
        onChanged: (value) {
          _onChanged(value, requestProvider, data);
        },
      );
    }

    if ((widget.type == DataInputType.select ||
            widget.type == DataInputType.multiSelect) &&
        widget.options != null &&
        !widget.disabled) {
      return _buildDropdown(decoration, value, requestProvider, data, error);
    }

    return TextFormField(
      controller: _controller,
      style: TextStyle(
        color: widget.disabled
            ? ThemeColors.getDisabledTextColor(context)
            : ThemeColors.getTextColor(context),
        fontSize: inputFontSize,
      ),
      obscureText: widget.type == DataInputType.password,
      maxLength: widget.type == DataInputType.date ? 10 : widget.maxLength,
      keyboardType:
          (widget.type == DataInputType.number ||
              widget.type == DataInputType.time ||
              widget.type == DataInputType.date)
          ? TextInputType.number
          : null,
      maxLines: widget.type == DataInputType.textArea ? 2 : 1,
      minLines: widget.type == DataInputType.textArea ? 2 : 1,
      textInputAction: widget.isLast
          ? TextInputAction.done
          : TextInputAction.next,
      enabled: !widget.disabled,
      decoration: decoration,
      textCapitalization: widget.allCaps
          ? TextCapitalization.characters
          : widget.capitalize
          ? TextCapitalization.words
          : widget.capitalizeFirst
          ? TextCapitalization.sentences
          : TextCapitalization.none,
      autofocus: widget.autoFocus,
      inputFormatters:
          widget.type == DataInputType.number && widget.wholeNumbersOnly
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      onChanged: (value) {
        var currentValue = value;
        if (widget.type == DataInputType.number &&
            widget.prefixText != null &&
            widget.prefixText!.isNotEmpty) {
          final trimmedValue = value.trim();
          final displayValue = trimmedValue.startsWith(widget.prefixText!)
              ? trimmedValue.substring(widget.prefixText!.length)
              : trimmedValue;
          currentValue = trimmedValue.startsWith(widget.prefixText!)
              ? trimmedValue
              : (trimmedValue.isEmpty
                    ? ''
                    : '${widget.prefixText!}$trimmedValue');
          _controller.value = TextEditingValue(
            text: displayValue,
            selection: TextSelection.collapsed(offset: displayValue.length),
          );
        }

        if (widget.type == DataInputType.date) {
          if (currentValue.length == 2 || currentValue.length == 5) {
            currentValue += '/';
          } else if (currentValue.length == 3 && currentValue[2] != '/') {
            currentValue =
                '${currentValue.substring(0, 2)}/${currentValue.substring(2)}';
          } else if (currentValue.length == 6 && currentValue[5] != '/') {
            currentValue =
                '${currentValue.substring(0, 5)}/${currentValue.substring(5)}';
          } else if (currentValue.endsWith('/')) {
            currentValue = currentValue.substring(0, currentValue.length - 1);
          } else if (currentValue.length > 10) {
            currentValue = currentValue.substring(0, 10);
          }

          if (currentValue.length == 10) {
            currentValue = convertUiDateToSqlDate(currentValue);
          }
        } else if (widget.type == DataInputType.time) {
          if (currentValue.length == 2 || currentValue.length == 5) {
            currentValue += ':';
          } else if (currentValue.length == 3 && currentValue[2] != ':') {
            currentValue =
                '${currentValue.substring(0, 2)}:${currentValue.substring(2)}';
          } else if (currentValue.length == 6 && currentValue[5] != ':') {
            currentValue =
                '${currentValue.substring(0, 5)}:${currentValue.substring(5)}';
          } else if (currentValue.endsWith(':')) {
            currentValue = currentValue.substring(0, currentValue.length - 1);
          } else if (currentValue.length > 8) {
            currentValue = currentValue.substring(0, 8);
          }
        }

        _onChanged(currentValue, requestProvider, data);
      },
    );
  }

  Widget _buildDropdown(
    InputDecoration decoration,
    dynamic value,
    RequestProvider requestProvider,
    Map data,
    String? error,
  ) {
    List? disabledValues;
    if (widget.isInitialValueDisabled) {
      final disabledDataKey = '${widget.dataKey}-disabled';
      if (widget.disabledValues != null) {
        disabledValues = List.from(widget.disabledValues!);
        data[disabledDataKey] = List.from(widget.disabledValues!);
      } else if (value != null && value is List) {
        disabledValues = data.containsKey(disabledDataKey)
            ? data[disabledDataKey]
            : null;
        if (disabledValues == null) {
          disabledValues = List.from(data[widget.dataKey]);
          data[disabledDataKey] = disabledValues;
        }
      } else {
        data[disabledDataKey] = null;
      }
    }

    return Dropdown(
      options: widget.options,
      optionsKey: widget.optionsKey,
      isInitialValueDisabled: widget.isInitialValueDisabled,
      disabledValues: disabledValues,
      isMultiSelect: widget.type == DataInputType.multiSelect,
      title: widget.title,
      placeholder: widget.placeholder,
      error: error,
      disabled: widget.disabled,
      value: value,
      onChanged: (value) {
        _onChanged(value, requestProvider, data);
      },
    );
  }
}
