import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heidi/src/data/model/model_forum_group.dart';
import 'package:heidi/src/data/model/model_setting.dart';
import 'package:heidi/src/presentation/main/home/list_product/cubit/cubit.dart';
import 'package:heidi/src/presentation/widget/app_forum_group_item.dart';
import 'package:heidi/src/presentation/widget/app_navbar.dart';
import 'package:heidi/src/presentation/widget/app_product_item.dart';
import 'package:heidi/src/utils/configs/application.dart';
import 'package:heidi/src/utils/configs/routes.dart';
import 'package:heidi/src/utils/translate.dart';

import 'cubit/cubit.dart';

class ListGroupScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const ListGroupScreen({Key? key, required this.arguments}) : super(key: key);

  @override
  State<ListGroupScreen> createState() => _ListGroupScreenState();
}

class _ListGroupScreenState extends State<ListGroupScreen> {
  GroupFilter? selectedFilter;
  int pageNo = 1;

  @override
  void initState() {
    super.initState();
    loadListingsList();
  }

  Future<void> loadListingsList() async {
    await context.read<ListCubit>().onLoad(widget.arguments['id']);
  }

  void _onAddGroup() async {
    final userId = await context.read<ListGroupsCubit>().getLoggedInUserId();
    if (userId == 0) {
      if (!mounted) return;
      final result = await Navigator.pushNamed(
        context,
        Routes.signIn,
        arguments: Routes.addGroups,
      ).then((value) {
        context.read<ListGroupsCubit>().onLoad();
        //setState(() {});
      });
      if (result == null) return;
    } else {
      if (!mounted) return;
      Navigator.pushNamed(context, Routes.addGroups,
          arguments: {'isNewGroup': true}).then((value) async {
        if (!mounted) return;
        await context.read<ListGroupsCubit>().onLoad();
        //setState(() {});
      });
    }
  }

  void _updateSelectedFilter(GroupFilter? filter) {
    final loadedList = context.read<ListGroupsCubit>().getLoadedList();
    setState(() {
      if (selectedFilter == filter) {
        selectedFilter = null;
        context.read<ListGroupsCubit>().onGroupFilter(null, loadedList);
      } else {
        selectedFilter = filter;
        context.read<ListGroupsCubit>().onGroupFilter(filter, loadedList);
      }
    });
  }

  Widget _buildTickIcon(bool isSelected) {
    return isSelected
        ? const Icon(
            Icons.done,
            color: Colors.white,
            size: 20,
            weight: 900,
          )
        : const SizedBox(width: 20);
  }

  Future<void> _openFilterDrawer(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Theme.of(context).dialogBackgroundColor,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      style: TextButton.styleFrom(),
                      onPressed: () {
                        _updateSelectedFilter(GroupFilter.myGroups);
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Text(
                            Translate.of(context).translate('my_groups'),
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                            ),
                          ),
                          const SizedBox(width: 5),
                          _buildTickIcon(
                              selectedFilter == GroupFilter.myGroups),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                height: 1,
                thickness: 1,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.groups,
                      color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      style: TextButton.styleFrom(),
                      onPressed: () {
                        _updateSelectedFilter(GroupFilter.allGroups);
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Text(
                            Translate.of(context).translate('all_groups'),
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                            ),
                          ),
                          const SizedBox(width: 5),
                          _buildTickIcon(
                              selectedFilter == GroupFilter.allGroups),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            Translate.of(context).translate(widget.arguments['title']),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await _openFilterDrawer(context);
              },
              style: TextButton.styleFrom(
                textStyle: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              icon: Icon(
                Icons.filter_list_rounded,
                color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                width: 40.0,
                height: 40.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: _onAddGroup,
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: BlocConsumer<ListGroupsCubit, ListGroupsState>(
          listener: (context, state) {
            state.maybeWhen(
              error: (msg) => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(msg))),
              orElse: () {},
            );
          },
          builder: (context, state) => state.when(
            loading: () => const ListLoading(),
            loaded: (list, userId) => ListLoaded(
              list: list,
              selectedCityId: widget.arguments['id'],
              userId: userId,
            ),
            updated: (list, userId) {
              return ListLoaded(
                list: list,
                selectedCityId: widget.arguments['id'],
                userId: userId,
              );
            },
            error: (e) => ErrorWidget('Failed to load listings.'),
            initial: () {
              return Container();
            },
          ),
        ),
      ),
    );
  }
}

class ListLoading extends StatelessWidget {
  const ListLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }
}

class ListLoaded extends StatefulWidget {
  final List<ForumGroupModel> list;
  final int selectedCityId;
  final int userId;

  const ListLoaded({
    Key? key,
    required this.list,
    required this.selectedCityId,
    required this.userId,
  }) : super(key: key);

  @override
  State<ListLoaded> createState() => _ListLoadedState();
}

class _ListLoadedState extends State<ListLoaded> {
  final _scrollController = ScrollController(initialScrollOffset: 0.0);
  bool isLoadingMore = false;
  final PageType _pageType = PageType.list;
  final ProductViewType _listMode = Application.setting.listMode;
  double previousScrollPosition = 0;
  int pageNo = 1;
  List<ForumGroupModel>? list;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    list = widget.list;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollListener() async {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0) {
        setState(() {
          isLoadingMore = true;
          previousScrollPosition = _scrollController.position.pixels;
        });
        list = await context.read<ListGroupsCubit>().newListings(++pageNo);

        setState(() {
          // list = [];
          // list = response;
          isLoadingMore = false;
          // list!.clear();
          // list!.addAll(response);
        });
        //     .then((_) {
        //   setState(() {
        //     isLoadingMore = false;
        //   });
        // }).catchError(
        //   (error) {
        //     setState(() {
        //       isLoadingMore = false;
        //     });
        //     logError('Error loading more listings: $error');
        //   },
        // );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: <Widget>[
          Expanded(
            child: _buildContent(list!),
          )
        ],
      ),
    );
  }

  Widget _buildItem({
    ForumGroupModel? item,
    required ProductViewType type,
  }) {
    if (item != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ForumGroupItem(
          userId: widget.userId,
          onPressed: (value) async {
            if (value) {
              Navigator.pushNamed(context, Routes.groupDetails, arguments: item)
                  .then((value) async {
                await context.read<ListGroupsCubit>().onLoad();
                //setState(() {});
              });
            } else {
              final popUpResult = await _showLoginPopup(context);
              if (popUpResult == true) {
                if (!mounted) return;

                await Navigator.pushNamed(
                  context,
                  Routes.signIn,
                  arguments: Routes.submit,
                ).then((value) async {
                  await context.read<ListGroupsCubit>().onLoad();
                  //setState(() {});
                });
              }
            }
          },
          item: item,
          fromGroupList: true,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppProductItem(
        type: _listMode,
        isRefreshLoader: true,
      ),
    );
  }

  Widget _buildContent(List<ForumGroupModel> list) {
    return BlocBuilder<ListCubit, ListState>(
      builder: (context, state) {
        if (_pageType == PageType.list) {
          Widget contentList = CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final item = list[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildItem(item: item, type: _listMode),
                    );
                  },
                  childCount: list.length,
                ),
              ),
            ],
          );

          if (list.isEmpty) {
            contentList = Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.sentiment_satisfied),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      Translate.of(context).translate('list_is_empty'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: Stack(
              children: [
                contentList,
                if (isLoadingMore)
                  const Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }

  Future<dynamic> _showLoginPopup(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Translate.of(context).translate('login_required')),
          content: Text(Translate.of(context)
              .translate('Please_log_in_to_enter_any_group.')),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
              child: Text(Translate.of(context).translate('login')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Close the dialog
              },
              child: Text(Translate.of(context).translate('cancel')),
            ),
          ],
        );
      },
    );
  }
}
