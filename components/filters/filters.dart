import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zpevnik/components/selector_widget.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/models/song_lyric.dart';
import 'package:zpevnik/models/tag.dart';
import 'package:zpevnik/components/filters/filters_section.dart';
import 'package:zpevnik/providers/sort.dart';
import 'package:zpevnik/providers/tags.dart';
import 'package:zpevnik/utils/extensions.dart';

class FiltersWidget extends ConsumerWidget {
  const FiltersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: ListView.builder(
        controller: PrimaryScrollController.of(context),
        padding: EdgeInsets.only(
          top: context.isSearching ? 0 : kDefaultPadding,
          bottom: MediaQuery.paddingOf(context).bottom,
        ),
        addRepaintBoundaries: false,
        itemCount: supportedTagTypes.length + 1,
        itemBuilder: (_, index) {
          // first row is sorting options for song lyrics
          if (index == 0) {
            return Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: kDefaultPadding),
                    child: Text('Řazení písní', style: Theme.of(context).textTheme.titleLarge),
                  ),
                ),
                SelectorWidget(
                  segments: const [
                    ButtonSegment(value: SortType.random, label: Icon(Icons.shuffle)),
                    ButtonSegment(value: SortType.alpha, label: Icon(Icons.sort_by_alpha)),
                    ButtonSegment(value: SortType.numeric, label: Icon(Icons.pin_outlined)),
                  ],
                  selected: ref.watch(sortProvider),
                  onSelected: (sortType) => ref.read(sortProvider.notifier).change(sortType),
                )
              ],
            );
          }

          index--;

          return FiltersSection(
            title: supportedTagTypes[index].description,
            tags: ref.watch(tagsProvider(supportedTagTypes[index])),
          );
        },
      ),
    );
  }
}
