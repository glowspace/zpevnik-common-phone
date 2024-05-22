import 'package:flutter/material.dart';
import 'package:zpevnik/components/filters/filters.dart';
import 'package:zpevnik/components/filters/filters_row.dart';
import 'package:zpevnik/components/navigation/scaffold.dart';
import 'package:zpevnik/components/search/search_field.dart';
import 'package:zpevnik/components/search/search_song_lyrics_list_view.dart';
import 'package:zpevnik/components/selected_displayable_item_arguments.dart';
import 'package:zpevnik/components/split_view.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/providers/search.dart';
import 'package:zpevnik/providers/tags.dart';
import 'package:zpevnik/routing/arguments.dart';
import 'package:zpevnik/utils/extensions.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final appBar = AppBar(
      automaticallyImplyLeading: false,
      // top padding is added only if there is no padding from safe area (e.g. when phone is in landscape)
      toolbarHeight: 100 + (mediaQuery.padding.top == 0 ? kDefaultPadding : 0),
      flexibleSpace: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // top padding is added only if there is no padding from safe area (e.g. when phone is in landscape)
            if (mediaQuery.padding.top == 0) const SizedBox(height: kDefaultPadding),
            SearchField(
              key: const Key('searchfield'),
              onChanged: context.providers.read(searchTextProvider.notifier).change,
              onSubmitted: (_) => _maybePushMatchedSonglyric(context),
            ),
            const Padding(
              padding: EdgeInsets.only(left: kDefaultPadding),
              child: FiltersRow(),
            ),
          ],
        ),
      ),
    );

    final Widget child;

    if (mediaQuery.isTablet && context.isSearching) {
      child = SplitView(
        // we want detail on left
        textDirection: TextDirection.rtl,
        maxChildWidth: 520.0,
        childWidthFactor: 0.4,
        detail: CustomScaffold(appBar: appBar, body: const SearchSongLyricsListView()),
        child: const Scaffold(body: FiltersWidget()),
      );
    } else {
      child = CustomScaffold(appBar: appBar, body: const SearchSongLyricsListView());
    }

    return PopScope(
      onPopInvoked: (_) {
        if (context.isSearching) context.providers.read(selectedTagsProvider.notifier).pop();
      },
      child: child,
    );
  }

  void _maybePushMatchedSonglyric(BuildContext context) {
    final matchedById = context.providers.read(searchedSongLyricsProvider).matchedById;

    if (matchedById == null) return;

    final arguments = ModalRoute.of(context)?.settings.arguments;
    final selectedDisplayableItemArgumentsNotifier = SelectedDisplayableItemArguments.of(context);

    if (arguments is SearchScreenArguments && arguments.shouldReturnSongLyric) {
      Navigator.of(context).pop(matchedById);
    } else if (selectedDisplayableItemArgumentsNotifier != null) {
      selectedDisplayableItemArgumentsNotifier.value = DisplayScreenArguments.songLyric(matchedById);
    } else {
      context.push('/display', arguments: DisplayScreenArguments.songLyric(matchedById, showSearchScreen: true));
    }
  }
}
