import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zpevnik/components/filters/add_filter_tag.dart';
import 'package:zpevnik/components/filters/filters.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/components/split_view.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/components/filters/filter_tag.dart';
import 'package:zpevnik/providers/tags.dart';
import 'package:zpevnik/utils/extensions.dart';

class FiltersRow extends ConsumerWidget {
  const FiltersRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTags = ref.watch(selectedTagsProvider);

    return Container(
      margin: const EdgeInsets.only(top: kDefaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Highlightable(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
            shrinkWrap: true,
            onTap: () => _showFilters(context),
            icon: const Icon(Icons.filter_alt),
          ),
          const SizedBox(width: kDefaultPadding / 2),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                ...selectedTags.map((tag) => FilterTag(tag: tag, isRemovable: true)),
                if (!MediaQuery.of(context).isTablet ||
                    0.6 * MediaQuery.sizeOf(context).width < kDefaultSplitViewDetailMinWidth ||
                    !context.isSearching)
                  AddFilterTag(onTap: () => _showFilters(context)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 2 / 3 * MediaQuery.sizeOf(context).height,
        child: const FiltersWidget(),
      ),
      routeSettings: const RouteSettings(name: '/filters'),
    );
  }
}
