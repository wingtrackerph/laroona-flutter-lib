import 'package:flutter/material.dart';
import 'package:laroona_flutter_lib/providers/request_provider.dart';
import 'package:laroona_flutter_lib/resources/dimensions.dart';
import 'package:laroona_flutter_lib/utils/theme_helper.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class DataModal extends StatefulWidget {
  const DataModal({
    super.key,
    required this.requestKey,
    required this.requestPath,
    this.title,
    this.label,
    required this.body,
    this.data,
    this.closeAfterSave = true,
    this.onPreSave,
    this.onDataSaved,
    this.showToast = true,
    this.showErrorToastForAllError = false,
  });

  final String requestKey;
  final String requestPath;
  final String? title;
  final String? label;
  final Widget body;
  final Map? data;
  final bool closeAfterSave;
  final Function()? onPreSave;
  final Function(dynamic responseData, dynamic savedData)? onDataSaved;
  final bool showToast;
  final bool showErrorToastForAllError;

  @override
  State<DataModal> createState() => _DataModalState();
}

class _DataModalState extends State<DataModal> {
  @override
  void initState() {
    super.initState();
    final requestProvider = Provider.of<RequestProvider>(
      context,
      listen: false,
    );
    final postRequest = requestProvider.getPostRequest(widget.requestKey);
    postRequest.errors = null;
    postRequest.errorMessage = null;
    postRequest.postData = widget.data != null
        ? Map.from(widget.data!)
        : {'id': 0};
  }

  void _copyData(Map existingData, Map newData) {
    for (var key in newData.keys) {
      if (existingData.containsKey(key)) {
        existingData[key] = newData[key];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<RequestProvider>(context, listen: true);
    final postRequest = requestProvider.getPostRequest(widget.requestKey);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ThemeColors.getBgColor(context),
          title: Text(
            widget.title ??
                (postRequest.isForCreation()
                    ? 'Add ${widget.label}'
                    : 'Edit ${widget.label}'),
            style: TextStyle(
              fontSize: appBarFontSize,
              color: ThemeColors.getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1),
          ),
          actions: [
            IconButton(
              icon: postRequest.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeColors.getPrimaryColor(context),
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ThemeColors.getPrimaryColor(
                          context,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.save,
                        color: ThemeColors.getPrimaryColor(context),
                      ),
                    ),
              onPressed: postRequest.isLoading
                  ? null
                  : () {
                      if (widget.onPreSave != null) {
                        final result = widget.onPreSave!();
                        if (result != null && result == false) {
                          return;
                        }
                      }

                      requestProvider.submitPostRequest(
                        context: context,
                        key: widget.requestKey,
                        path: widget.requestPath,
                        showToast: widget.showToast,
                        showErrorToastForAllError:
                            widget.showErrorToastForAllError,
                        onSuccess: (response) {
                          if (widget.data != null) {
                            _copyData(widget.data!, postRequest.postData);
                          }

                          if (mounted && widget.closeAfterSave) {
                            PersistentNavBarNavigator.pop(context);
                          }

                          if (widget.onDataSaved != null) {
                            widget.onDataSaved!(response, postRequest.postData);
                          }
                        },
                      );
                    },
            ),
          ],
        ),
        body: Container(
          color: ThemeColors.getBgColor(context),
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  top: pagePaddingSize,
                  left: pagePaddingSize,
                  right: pagePaddingSize,
                  bottom: paddingSizeXXXLarge,
                ),
                color: ThemeColors.getBgColor(context),
                child: widget.body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
