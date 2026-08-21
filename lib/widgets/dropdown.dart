import 'package:collection/collection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:laroona_flutter_lib/resources/dimensions.dart';
import 'package:laroona_flutter_lib/utils/theme_helper.dart';

class Dropdown extends StatefulWidget {
  const Dropdown({
    super.key,
    this.options,
    this.optionsKey,
    this.isInitialValueDisabled = false,
    this.disabledValues,
    this.isMultiSelect = false,
    this.title,
    this.placeholder,
    this.error,
    this.disabled = false,
    this.value,
    this.onChanged,
  });

  final List? options;
  final String? optionsKey;
  final bool isInitialValueDisabled;
  final List? disabledValues;
  final bool isMultiSelect;
  final String? title;
  final String? placeholder;
  final String? error;
  final bool disabled;
  final dynamic value;
  final Function(dynamic value)? onChanged;

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stringOptions = <String>[];

    var values = <dynamic>[];
    if (widget.value != null) {
      if (widget.value is List) {
        values = widget.value;
      } else if ((widget.value is String && widget.value.isNotEmpty) ||
          widget.value is! String) {
        values = [widget.value];
      }
    }

    String? selectedValue;
    var selectedItem = '';
    final selectedValues = <String>[];
    for (var option in widget.options!) {
      final stringOption = option[widget.optionsKey];
      stringOptions.add(stringOption);
      for (var value in values) {
        if (value.toString() == option['id'].toString()) {
          selectedValues.add(stringOption);
          break;
        }
      }
    }

    if (selectedValues.isNotEmpty) {
      selectedValue = selectedValues.last;
      selectedItem = selectedValues.join(', ');
    }

    final decoration = InputDecoration(
      hintText: widget.placeholder,
      labelText: widget.title,
      fillColor: Colors.white,
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
      errorText: widget.error,
    );

    return DropdownButtonFormField2<String>(
      isExpanded: true,
      valueListenable: ValueNotifier<String?>(selectedValue),
      decoration: decoration,
      style: TextStyle(
        color: ThemeColors.getTextColor(context),
        fontSize: inputFontSize,
      ),
      items: widget.disabled
          ? null
          : stringOptions
                .map((item) => _buildDropdownItem(item, values))
                .toList(),
      onChanged: (value) {
        if (value != null) {
          final option = widget.options!.firstWhereOrNull(
            (option) => option[widget.optionsKey] == value,
          );
          if (option != null && widget.onChanged != null) {
            widget.onChanged!(option['id']);
          }
        }
      },
      selectedItemBuilder: (context) {
        return stringOptions.map((item) {
          return Text(
            selectedItem,
            style: const TextStyle(
              fontSize: inputFontSize,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          );
        }).toList();
      },
      dropdownStyleData: const DropdownStyleData(maxHeight: 400),
      dropdownSearchData: DropdownSearchData(
        searchController: _searchController,
        searchBarWidgetHeight: 50,
        searchBarWidget: Container(
          height: 60,
          padding: const EdgeInsets.all(paddingSizeXXXSmall),
          child: TextFormField(
            expands: true,
            maxLines: null,
            controller: _searchController,
            decoration: const InputDecoration(hintText: 'Search'),
          ),
        ),
        searchMatchFn: (item, searchValue) {
          return item.value.toString().toLowerCase().contains(
            searchValue.toLowerCase(),
          );
        },
      ),
      //This to clear the search value when you close the menu
      onMenuStateChange: (isOpen) {
        if (!isOpen) {
          _searchController.clear();
        }
      },
    );
  }

  DropdownItem<String> _buildDropdownItem(String item, List values) {
    if (!widget.isMultiSelect) {
      return DropdownItem(
        value: item,
        child: Text(item, style: const TextStyle(fontSize: inputFontSize)),
      );
    }

    return DropdownItem(
      value: item,
      //disable default onTap to avoid closing menu when selecting an item
      enabled: false,
      child: StatefulBuilder(
        builder: (context, menuSetState) {
          final option = widget.options!.firstWhereOrNull(
            (option) => option[widget.optionsKey] == item,
          );
          final optionId = option != null ? option['id'] : 0;

          final isSelected = values.contains(optionId);
          var isDisabled = false;
          if (widget.disabledValues != null) {
            isDisabled =
                widget.disabledValues!.firstWhereOrNull(
                  (value) => value == optionId,
                ) !=
                null;
          }
          return InkWell(
            onTap: isDisabled
                ? null
                : () {
                    isSelected ? values.remove(optionId) : values.add(optionId);
                    if (widget.onChanged != null) {
                      widget.onChanged!(values);
                    }
                    //This rebuilds the dropdownMenu Widget to update the check mark
                    menuSetState(() {});
                  },
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: paddingSizeSmall),
              child: Row(
                children: [
                  if (isSelected)
                    Icon(
                      Icons.check_box_outlined,
                      color: isDisabled
                          ? ThemeColors.getDisabledTextColor(context)
                          : ThemeColors.getTextColor(context),
                    )
                  else
                    Icon(
                      Icons.check_box_outline_blank,
                      color: isDisabled
                          ? ThemeColors.getDisabledTextColor(context)
                          : ThemeColors.getTextColor(context),
                    ),
                  const SizedBox(width: paddingSizeSmall),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: inputFontSize,
                        color: isDisabled
                            ? ThemeColors.getDisabledTextColor(context)
                            : ThemeColors.getTextColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
