import 'package:flutter/material.dart';
import 'package:laroona_flutter_lib/utils/theme_helper.dart';
import 'package:laroona_flutter_lib/widgets/app_card.dart';
import 'package:laroona_flutter_lib/widgets/loading_spinner.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:laroona_flutter_lib/providers/request_provider.dart';
import 'package:laroona_flutter_lib/resources/dimensions.dart';

class DataListView extends StatefulWidget {
  const DataListView({
    super.key,
    required this.requestKey,
    required this.requestPath,
    this.pageSize = 10,
    this.isInfiniteScroll = true,
    this.noResultWidget,
    required this.onItemBuild,
    this.onItemPressed,
    this.controller,
    this.horizontalPadding = pagePaddingSize,
    this.isItemInCard = true,
    this.emptyListMessage,
    this.onInitialLoad,
    this.onRefresh,
    this.onLoaded,
  });

  final String requestKey;
  final String requestPath;
  final int pageSize;
  final bool isInfiniteScroll;
  final Widget? noResultWidget;
  final Widget Function(dynamic item, int index) onItemBuild;
  final Function(dynamic item)? onItemPressed;
  final DataListViewController? controller;
  final double horizontalPadding;
  final bool isItemInCard;
  final String? emptyListMessage;
  final Function()? onInitialLoad;
  final Future<void> Function()? onRefresh;
  final Function()? onLoaded;

  @override
  State<DataListView> createState() => _DataListViewState();
}

class _DataListViewState extends State<DataListView> {
  late RefreshController _refreshController;
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  bool _hasInitialLoaded = false;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    _scrollController = ScrollController();

    if (widget.controller != null) {
      widget.controller!.onSearchCallback = (String queryText) async {
        if (!mounted) {
          return;
        }

        await _loadData(
          forceFetch: true,
          restartPage: true,
          queryText: queryText,
        );
      };

      widget.controller!.onRefreshCallback =
          ({bool preserveScrollOffset = false}) async {
            if (!mounted) {
              return;
            }

            await _loadData(
              forceFetch: true,
              restartPage: true,
              preserveScrollOffset: preserveScrollOffset,
            );
          };
    }

    Future.delayed(Duration.zero, () {
      if (!mounted) {
        return;
      }

      _loadData(forceFetch: true, restartPage: true);
    });
  }

  Future<void> _loadData({
    bool forceFetch = false,
    bool restartPage = false,
    String? queryText,
    bool preserveScrollOffset = false,
  }) async {
    if (!mounted) {
      return;
    }

    final previousOffset = preserveScrollOffset && _scrollController.hasClients
        ? _scrollController.offset
        : null;

    final requestProvider = Provider.of<RequestProvider>(
      context,
      listen: false,
    );

    if (queryText != null) {
      final request = requestProvider.getRequest(widget.requestKey);
      request.queryText = queryText;
    }

    await requestProvider.fetchRequest(
      context,
      key: widget.requestKey,
      path: widget.requestPath,
      pageSize: widget.pageSize,
      appendNewData: widget.isInfiniteScroll,
      forceFetch: forceFetch,
      restartPage: restartPage,
    );

    if (!mounted) {
      return;
    }

    if (previousOffset != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) {
          return;
        }

        final maxExtent = _scrollController.position.maxScrollExtent;
        final targetOffset = previousOffset.clamp(0.0, maxExtent);
        _scrollController.jumpTo(targetOffset);
      });
    }

    if (restartPage &&
        queryText == null &&
        widget.onInitialLoad != null &&
        !_hasInitialLoaded) {
      widget.onInitialLoad!();
      _hasInitialLoaded = true;
    }

    // Call onLoaded callback after data is loaded
    if (widget.onLoaded != null) {
      widget.onLoaded!();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    if (!mounted) {
      return;
    }

    // Call custom onRefresh callback if provided
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    }

    if (!mounted) {
      return;
    }

    await _loadData(forceFetch: true, restartPage: true);
    if (mounted) {
      _refreshController.refreshCompleted();
    }
  }

  void _onLoading() async {
    if (!mounted) {
      return;
    }

    _isLoadingMore = true;
    await _loadData(forceFetch: true);
    if (mounted) {
      _refreshController.loadComplete();
    }
    _isLoadingMore = false;
  }

  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<RequestProvider>(context, listen: true);
    final request = requestProvider.getRequest(widget.requestKey);
    final items = request.filteredData ?? request.data;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: (!_isLoadingMore && (request.isLoading || !request.isDone))
          ? const LoadingSpinner()
          : Padding(
              padding: const EdgeInsets.only(top: paddingSizeXXSmall),
              child: SmartRefresher(
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                enablePullUp: request.isPaginated,
                child: items.isEmpty
                    ? widget.noResultWidget ?? _buildDefaultNoResultWidget()
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          if (widget.isItemInCard) {
                            return AppCard(
                              horizontalMargin: widget.horizontalPadding,
                              bottomMargin: paddingSizeXXSmall,
                              paddingVertical: paddingSizeXXSmall,
                              child: widget.onItemBuild(items[index], index),
                            );
                          }

                          return Padding(
                            padding: EdgeInsets.only(
                              left: widget.horizontalPadding,
                              right: widget.horizontalPadding,
                              bottom: paddingSizeXXSmall,
                            ),
                            child: widget.onItemBuild(items[index], index),
                          );
                        },
                      ),
              ),
            ),
    );
  }

  Widget _buildDefaultNoResultWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: paddingSize),
          Text(
            widget.emptyListMessage ?? 'No data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeColors.getGrayTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

class DataListViewController {
  Future<void> Function(String queryText)? onSearchCallback;
  Future<void> Function({bool preserveScrollOffset})? onRefreshCallback;

  Future<void> search(String queryText) async {
    if (onSearchCallback != null) {
      await onSearchCallback!(queryText);
    }
  }

  Future<void> refresh({bool preserveScrollOffset = false}) async {
    if (onRefreshCallback != null) {
      await onRefreshCallback!(preserveScrollOffset: preserveScrollOffset);
    }
  }
}
