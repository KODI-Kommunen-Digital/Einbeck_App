import 'package:flutter/material.dart';
import 'package:heidi/src/data/model/model_multifilter.dart';
import 'package:heidi/src/presentation/main/home/forum/list_groups/cubit/cubit.dart';
import 'package:heidi/src/presentation/main/home/list_product/cubit/list_cubit.dart';
import 'package:heidi/src/utils/translate.dart';

class FilterScreen extends StatefulWidget {
  final MultiFilter multiFilter;

  const FilterScreen({super.key, required this.multiFilter});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  int? currentCity;
  List<int> currentCities = [];
  int? currentCategory;
  int? currentListingStatus;
  ProductFilter? currentProductEventFilter;
  GroupFilter? currentForumGroupFilter;

  @override
  void initState() {
    super.initState();
    if (widget.multiFilter.multipleCityFilter) {
      currentCities = widget.multiFilter.currentLocation.cast<int>();
    } else {
      currentCity = widget.multiFilter.currentLocation;
    }
    currentCategory = widget.multiFilter.currentCategory;
    currentProductEventFilter = widget.multiFilter.currentProductEventFilter;
    currentListingStatus = widget.multiFilter.currentListingStatus;
    currentForumGroupFilter = widget.multiFilter.currentForumGroupFilter;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Filter"),
      ),
      body: SingleChildScrollView(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) async {
            if (didPop) return;
            Navigator.pop(
                context,
                MultiFilter(
                    currentLocation: (widget.multiFilter.multipleCityFilter)
                        ? currentCities
                        : currentCity,
                    currentProductEventFilter: currentProductEventFilter,
                    currentListingStatus: currentListingStatus,
                    currentForumGroupFilter: currentForumGroupFilter,
                    currentCategory: currentCategory,
                    hasForumGroupFilter: widget.multiFilter.hasForumGroupFilter,
                    hasProductEventFilter:
                        widget.multiFilter.hasProductEventFilter,
                    hasLocationFilter: widget.multiFilter.hasLocationFilter,
                    hasListingStatusFilter:
                        widget.multiFilter.hasListingStatusFilter,
                    hasCategoryFilter: widget.multiFilter.hasCategoryFilter));
          },
          child: Column(
            children: [
              if (widget.multiFilter.hasLocationFilter == true)
                ..._buildLocationFilter(),
              if (widget.multiFilter.hasProductEventFilter == true)
                ..._buildProductEventFilter(),
              if (widget.multiFilter.hasListingStatusFilter == true)
                ..._buildListingStatusFilter(),
              if (widget.multiFilter.hasForumGroupFilter == true)
                ..._buildForumGroupFilter(),
              if (widget.multiFilter.hasCategoryFilter == true)
                ..._buildCategoryFilter(),
            ],
          ),
        ),
      ),
    ));
  }

  List<Widget> _buildLocationFilter() {
    return [
      const SizedBox(
        height: 8,
      ),
      Center(
          child: Text(
        Translate.of(context).translate('choose_city'),
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontWeight: FontWeight.bold),
      )),
      Container(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(spacing: 8.0, children: [
          (widget.multiFilter.multipleCityFilter)
              ? ChoiceChip(
                  label:
                      Text(Translate.of(context).translate('select_location')),
                  selected: currentCities.contains(0),
                  onSelected: (selected) {
                    setState(() {
                      currentCities = [];
                      currentCities.add(0);
                    });
                  },
                )
              : ChoiceChip(
                  label:
                      Text(Translate.of(context).translate('select_location')),
                  selected: 0 == currentCity,
                  onSelected: (selected) {
                    setState(() {
                      currentCity = 0;
                    });
                  },
                ),
          ...widget.multiFilter.cities!.map((city) {
            return (widget.multiFilter.multipleCityFilter)
                ? ChoiceChip(
                    label: Text(city.title),
                    selected: currentCities.contains(city.id),
                    onSelected: (selected) {
                      setState(() {
                        if (currentCities.contains(city.id)) {
                          currentCities.remove(city.id);
                        } else {
                          currentCities.add(city.id);
                          currentCities.remove(0);
                        }
                      });
                    },
                  )
                : ChoiceChip(
                    label: Text(city.title),
                    selected: city.id == currentCity,
                    onSelected: (selected) {
                      setState(() {
                        currentCity = city.id;
                      });
                    },
                  );
          }),
        ]),
      )
    ];
  }

  List<Widget> _buildListingStatusFilter() {
    return [
      const SizedBox(
        height: 8,
      ),
      Center(
          child: Text(
        Translate.of(context).translate('choose_listing_status'),
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontWeight: FontWeight.bold),
      )),
      Container(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(spacing: 8.0, children: [
          ChoiceChip(
            label: Text(Translate.of(context).translate('all')),
            selected: currentListingStatus == 0,
            onSelected: (selected) {
              setState(() {
                currentListingStatus = 0;
              });
            },
          ),
          ChoiceChip(
            label: Text(Translate.of(context).translate('active')),
            selected: currentListingStatus == 1,
            onSelected: (selected) {
              setState(() {
                currentListingStatus = 1;
              });
            },
          ),
          ChoiceChip(
            label: Text(Translate.of(context).translate('inactive')),
            selected: currentListingStatus == 2,
            onSelected: (selected) {
              setState(() {
                currentListingStatus = 2;
              });
            },
          ),
          ChoiceChip(
            label: Text(Translate.of(context).translate('under_review')),
            selected: currentListingStatus == 3,
            onSelected: (selected) {
              setState(() {
                currentListingStatus = 3;
              });
            },
          ),
        ]),
      )
    ];
  }

  List<Widget> _buildForumGroupFilter() {
    return [
      const SizedBox(
        height: 8,
      ),
      Center(
          child: Text(
        Translate.of(context).translate('choose_forum'),
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontWeight: FontWeight.bold),
      )),
      Container(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(spacing: 8.0, children: [
          ChoiceChip(
            label: Text(Translate.of(context).translate('all')),
            selected: currentForumGroupFilter == null,
            onSelected: (selected) {
              setState(() {
                currentForumGroupFilter = null;
              });
            },
          ),
          ChoiceChip(
            label: Wrap(
              spacing: 4.0,
              children: [
                Text(Translate.of(context).translate('all_groups')),
                Icon(
                  Icons.groups,
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.white,
                  size: 18,
                )
              ],
            ),
            selected: currentForumGroupFilter == GroupFilter.allGroups,
            onSelected: (selected) {
              setState(() {
                currentForumGroupFilter = GroupFilter.allGroups;
              });
            },
          ),
          ChoiceChip(
            label: Wrap(
              spacing: 4.0,
              children: [
                Text(Translate.of(context).translate('my_groups')),
                Icon(
                  Icons.person,
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.white,
                  size: 18,
                )
              ],
            ),
            selected: currentForumGroupFilter == GroupFilter.myGroups,
            onSelected: (selected) {
              setState(() {
                currentForumGroupFilter = GroupFilter.myGroups;
              });
            },
          ),
        ]),
      )
    ];
  }

  List<Widget> _buildProductEventFilter() {
    return [
      const SizedBox(
        height: 8,
      ),
      Center(
          child: Text(
        Translate.of(context).translate('choose_time_period'),
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontWeight: FontWeight.bold),
      )),
      Container(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(spacing: 8.0, children: [
          ChoiceChip(
            label: Text(Translate.of(context).translate('all')),
            selected: currentProductEventFilter == null,
            onSelected: (selected) {
              setState(() {
                currentProductEventFilter = null;
              });
            },
          ),
          ChoiceChip(
            label: Wrap(
              spacing: 4.0,
              children: [
                Text(Translate.of(context).translate('this_month')),
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.white,
                  size: 18,
                )
              ],
            ),
            selected: currentProductEventFilter == ProductFilter.month,
            onSelected: (selected) {
              setState(() {
                currentProductEventFilter = ProductFilter.month;
              });
            },
          ),
          ChoiceChip(
            label: Wrap(
              spacing: 4.0,
              children: [
                Text(Translate.of(context).translate('this_week')),
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.white,
                  size: 18,
                )
              ],
            ),
            selected: currentProductEventFilter == ProductFilter.week,
            onSelected: (selected) {
              setState(() {
                currentProductEventFilter = ProductFilter.week;
              });
            },
          ),
        ]),
      )
    ];
  }

  List<Widget> _buildCategoryFilter() {
    return [
      const SizedBox(
        height: 8,
      ),
      Center(
          child: Text(
        Translate.of(context).translate('input_category'),
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontWeight: FontWeight.bold),
      )),
      Container(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(spacing: 8.0, children: [
          ChoiceChip(
            label: Text(Translate.of(context).translate('all_Categories')),
            selected: 0 == currentCategory,
            onSelected: (selected) {
              setState(() {
                currentCategory = 0;
              });
            },
          ),
          ...widget.multiFilter.categories!.map((category) {
            return ChoiceChip(
              label: Text(category.title),
              selected: category.id == currentCategory,
              onSelected: (selected) {
                setState(() {
                  currentCategory = category.id;
                });
              },
            );
          }),
        ]),
      )
    ];
  }
}
