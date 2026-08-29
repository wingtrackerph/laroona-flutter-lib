import 'dart:async';

import 'package:laroona_flutter_lib/resources/dimensions.dart';
import 'package:laroona_flutter_lib/utils/theme_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({
    super.key,
    this.title,
    this.titleIcon,
    this.titleIconSize = iconSize,
    this.icons,
    this.actionWidgets,
    this.onActionPressed,
    required this.body,
    this.middle,
    this.middleBottomSize = 20,
    this.middlePinned = false,
    this.hasBottomNavBar = true,
    this.isBottomNavBarVisible = false,
    this.bottomNavBarHeight = 60,
    this.tabs,
    this.onSearched,
    this.onTabChanged,
  });

  final String? title;
  final String? titleIcon;
  final double? titleIconSize;
  final List<IconData>? icons;
  final List<Widget>? actionWidgets;
  final Function(int index)? onActionPressed;

  final Widget body;
  final Widget? middle;
  final double middleBottomSize;
  final bool middlePinned;
  final bool hasBottomNavBar;
  final bool isBottomNavBarVisible;
  final double bottomNavBarHeight;
  final List<String>? tabs;
  final Function(String text)? onSearched;
  final Function(int tabIndex)? onTabChanged;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold>
    with TickerProviderStateMixin {
  Timer? _searchTimer;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    if (widget.tabs != null) {
      _tabController = TabController(length: widget.tabs!.length, vsync: this);
    }
  }

  @override
  void dispose() {
    if (_tabController != null) {
      _tabController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              _buildTitleAppBar(context),
              // if (widget.tabs != null) _buildTabBar(context),
              // if (widget.middle != null) _buildCustomAppBar(context),
              // if (widget.onSearched != null) _buildSearchAppBar(context),
            ];
          },
          body: Column(
            children: [
              if (widget.middle != null) widget.middle!,
              if (widget.onSearched != null) _buildSearchAppBar(context),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: widget.hasBottomNavBar
                        ? (widget.isBottomNavBarVisible
                              ? widget.bottomNavBarHeight +
                                    MediaQuery.of(context).padding.bottom
                              : 0)
                        : 0,
                  ),
                  color: ThemeColors.getBgColor(context),
                  child: kIsWeb
                      ? Center(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Responsive max width based on screen size
                              double maxWidth = webMaxWidth;
                              if (constraints.maxWidth < 1024) {
                                maxWidth = webMaxWidthSmall;
                              } else if (constraints.maxWidth < 1440) {
                                maxWidth = webMaxWidth;
                              } else {
                                maxWidth = webMaxWidthLarge;
                              }

                              return ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: maxWidth),
                                child: widget.body,
                              );
                            },
                          ),
                        )
                      : widget.body,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAppBar(BuildContext context) {
    if (widget.title == null) {
      return SliverAppBar(
        toolbarHeight: 20.0,
        pinned: true,
        backgroundColor: ThemeColors.getBgColor(context),
      );
    }

    return SliverAppBar(
      expandedHeight: 70.0,
      floating: false,
      pinned: true,
      centerTitle: false,
      backgroundColor: ThemeColors.getBgColor(context),
      elevation: 10,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.titleIcon != null) ...[
              Image.asset(widget.titleIcon!, height: widget.titleIconSize),
              const SizedBox(width: paddingSizeXXSmall),
            ],
            Text(
              widget.title!,
              style: TextStyle(
                fontSize: widget.title!.length < 16
                    ? appBarFontSize
                    : appBarFontSizeSmall,
                color: ThemeColors.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
              textScaler: TextScaler.noScaling,
            ),
          ],
        ),
      ),
      actions: _buildActionIcons(),
    );
  }

  List<Widget>? _buildActionIcons() {
    if ((widget.icons == null || widget.icons!.isEmpty) &&
        (widget.actionWidgets == null || widget.actionWidgets!.isEmpty)) {
      return null;
    }

    List<Widget> iconList = [];

    // Add custom action widgets if provided
    if (widget.actionWidgets != null) {
      for (var i = 0; i < widget.actionWidgets!.length; i++) {
        iconList.add(
          GestureDetector(
            onTap: () {
              if (widget.onActionPressed != null) {
                widget.onActionPressed!(i);
              }
            },
            child: widget.actionWidgets![i],
          ),
        );
      }
    }

    // Add icon buttons if provided
    if (widget.icons != null) {
      for (var i = 0; i < widget.icons!.length; i++) {
        iconList.add(
          IconButton(
            icon: Icon(widget.icons![i]),
            iconSize: iconSize,
            color: ThemeColors.getPrimaryColor(context),
            onPressed: () {
              if (widget.onActionPressed != null) {
                widget.onActionPressed!(i);
              }
            },
          ),
        );
      }
    }

    return iconList;
  }

  Widget _buildSearchAppBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Colors.transparent,
            margin: const EdgeInsets.symmetric(horizontal: pagePaddingSize),
            child: TextFormField(
              style: TextStyle(color: ThemeColors.getTextColor(context)),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                prefixIconColor: ThemeColors.getGrayTextColor(context),
                fillColor: ThemeColors.getCardColor(context),
                filled: true,
                border: InputBorder.none,
                hintText: "Search",
                hintStyle: TextStyle(
                  color: ThemeColors.getHintTextColor(context),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: paddingSizeXXSmall,
                  horizontal: paddingSizeXXSmall,
                ),
              ),
              onChanged: (text) {
                if (widget.onSearched != null) {
                  if (text.length >= 2 || text.isEmpty) {
                    if (_searchTimer != null) {
                      _searchTimer!.cancel();
                    }
                    _searchTimer = Timer(const Duration(seconds: 1), () {
                      widget.onSearched!(text);
                    });
                  }
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
