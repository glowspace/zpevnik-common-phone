import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zpevnik/components/custom/back_button.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/components/navigation/scaffold.dart';
import 'package:zpevnik/components/playlist/bible_verse.dart';
import 'package:zpevnik/components/playlist/custom_text.dart';
import 'package:zpevnik/components/playlist/playlists_sheet.dart';
import 'package:zpevnik/components/presentation/presentation.dart';
import 'package:zpevnik/components/selected_displayable_item_arguments.dart';
import 'package:zpevnik/components/presentation/settings.dart';
import 'package:zpevnik/components/song_lyric/bottom_bar.dart';
import 'package:zpevnik/components/song_lyric/externals/collapsed_player.dart';
import 'package:zpevnik/components/song_lyric/externals/externals_wrapper.dart';
import 'package:zpevnik/components/song_lyric/song_lyric.dart';
import 'package:zpevnik/components/song_lyric/song_lyric_menu_button.dart';
import 'package:zpevnik/components/song_lyric/utils/active_player_controller.dart';
import 'package:zpevnik/components/song_lyric/utils/auto_scroll.dart';
import 'package:zpevnik/components/split_view.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/models/bible_verse.dart';
import 'package:zpevnik/models/custom_text.dart';
import 'package:zpevnik/models/model.dart';
import 'package:zpevnik/models/playlist.dart';
import 'package:zpevnik/models/song_lyric.dart';
import 'package:zpevnik/models/songbook.dart';
import 'package:zpevnik/providers/menu_collapsed.dart';
import 'package:zpevnik/providers/playlists.dart';
import 'package:zpevnik/providers/presentation.dart';
import 'package:zpevnik/providers/recent_items.dart';
import 'package:zpevnik/providers/settings.dart';
import 'package:zpevnik/providers/display_screen_status.dart';
import 'package:zpevnik/routing/arguments.dart';
import 'package:zpevnik/screens/playlist.dart';
import 'package:zpevnik/screens/search.dart';
import 'package:zpevnik/screens/songbook.dart';
import 'package:zpevnik/utils/extensions.dart';

class DisplayScreen extends StatelessWidget {
  final List<DisplayableItem> items;
  final int initialIndex;

  final bool showSearchScreen;

  final Playlist? playlist;
  final Songbook? songbook;

  const DisplayScreen({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.showSearchScreen = false,
    this.playlist,
    this.songbook,
  });

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).isTablet && (showSearchScreen || playlist != null || songbook != null)) {
      return _DisplayScreenTablet(items: items, initialIndex: initialIndex, playlist: playlist, songbook: songbook);
    }

    return _DisplayScaffold(items: items, initialIndex: initialIndex);
  }
}

class _DisplayScreenTablet extends ConsumerStatefulWidget {
  final List<DisplayableItem> items;
  final int initialIndex;

  final Playlist? playlist;
  final Songbook? songbook;

  const _DisplayScreenTablet({required this.items, required this.initialIndex, this.playlist, this.songbook});

  @override
  ConsumerState<_DisplayScreenTablet> createState() => _DisplayScreenTabletState();
}

class _DisplayScreenTabletState extends ConsumerState<_DisplayScreenTablet> {
  late final _selectedDisplayableItemArgumentsNotifier = ValueNotifier(
    DisplayScreenArguments(items: widget.items, initialIndex: widget.initialIndex),
  );

  @override
  Widget build(BuildContext context) {
    final menuCollapsed = ref.watch(menuCollapsedProvider);
    final fullScreen = ref.watch(displayScreenStatusProvider.select((status) => status.fullScreen));

    return SelectedDisplayableItemArguments(
      displayableItemArgumentsNotifier: _selectedDisplayableItemArgumentsNotifier,
      child: SplitView(
        showingOnlyDetail: menuCollapsed || fullScreen,
        detail: _DisplayScaffold(items: widget.items, initialIndex: widget.initialIndex),
        child: widget.playlist != null
            ? PlaylistScreen(playlist: widget.playlist!)
            : (widget.songbook != null ? SongbookScreen(songbook: widget.songbook!) : const SearchScreen()),
      ),
    );
  }
}

class _DisplayScaffold extends ConsumerStatefulWidget {
  final List<DisplayableItem> items;
  final int initialIndex;

  const _DisplayScaffold({required this.items, required this.initialIndex});

  @override
  ConsumerState<_DisplayScaffold> createState() => _DisplayScaffoldState();
}

class _DisplayScaffoldState extends ConsumerState<_DisplayScaffold> {
  // make sure it is possible to swipe to previous item
  // this controller is only used to set the initial page
  late final _controller = PageController(initialPage: widget.initialIndex + 100 * widget.items.length);

  final _autoScrollControllers = <int, AutoScrollController>{};

  late List<DisplayableItem> _items = widget.items;

  late int _currentIndex;

  late double _fontSizeScaleBeforeScale;

  Timer? _addRecentItemTimer;

  DisplayableItem get _currentItem => _items[_currentIndex];

  AutoScrollController _autoScrollController(int index) {
    return _autoScrollControllers.putIfAbsent(index, () => AutoScrollController());
  }

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    // TODO: make sure this widget does not depend on `presentationProvider` and do this without delay
    Future.delayed(const Duration(milliseconds: 10), () => ref.read(presentationProvider).change(_currentItem));

    final selectedDisplayableItemArgumentsNotifier = SelectedDisplayableItemArguments.of(context, listen: false);

    selectedDisplayableItemArgumentsNotifier?.addListener(() {
      final newItems = selectedDisplayableItemArgumentsNotifier.value.items;
      final newIndex = selectedDisplayableItemArgumentsNotifier.value.initialIndex;

      if (newItems.hashCode != _items.hashCode) {
        setState(() => _items = newItems);

        if (newItems.length > 1) {
          // do this with delay, because if previous `_items` contained only one item `_controller` won't be attached until redraw
          Future.delayed(
            const Duration(milliseconds: 100),
            () => _controller.jumpToPage(newIndex + 100 * newItems.length),
          );
        }
        _itemChanged(newIndex);
      } else if (newIndex != _currentIndex % _items.length) {
        _controller.jumpToPage(newIndex + 100 * _items.length);
        _itemChanged(newIndex);
      }
    });
  }

  @override
  void dispose() {
    _addRecentItemTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // update media query with font size scale from settings, so all children has correct font size scale and it does not have to be set individually
    final newMediaQuery = MediaQuery.of(context)
        .copyWith(textScaleFactor: ref.watch(settingsProvider.select((settings) => settings.fontSizeScale)));

    final fullScreen = ref.watch(displayScreenStatusProvider.select((status) => status.fullScreen));

    final scaffold = CustomScaffold(
      appBar: fullScreen ? null : _buildAppBar(),
      bottomSheet: _buildBottomSheet(),
      bottomNavigationBar: fullScreen
          ? const SizedBox()
          : SongLyricBottomBar(
              songLyric: _currentItem is SongLyric ? _currentItem as SongLyric : null,
              autoScrollController: _autoScrollController(_currentIndex),
            ),
      body: GestureDetector(
        onScaleStart: _fontScaleStarted,
        onScaleUpdate: _fontScaleUpdated,
        onTap: ref.read(displayScreenStatusProvider.notifier).toggleFullScreen,
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          bottom: false,
          child: MediaQuery(
            data: newMediaQuery,
            child: PageView.builder(
              controller: _items.length == 1 ? null : _controller,
              onPageChanged: _itemChanged,
              itemCount: _items.length == 1 ? 1 : null,
              // disable scrolling when there is only one item
              physics: _items.length == 1 ? const NeverScrollableScrollPhysics() : null,
              itemBuilder: (_, index) {
                index = index % _items.length;
                final item = _items[index];

                if (ref.watch(presentationProvider
                    .select((presentation) => presentation.isPresenting && presentation.isPresentingLocally))) {
                  if (ref.watch(
                      presentationProvider.select((presentation) => presentation.presentationData.name == item.name))) {
                    return Consumer(
                      builder: (_, ref, __) => Presentation(
                        onExternalDisplay: false,
                        presentationData:
                            ref.watch(presentationProvider.select((presentation) => presentation.presentationData)),
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                }

                return switch (item) {
                  (BibleVerse bibleVerse) => BibleVerseWidget(
                      bibleVerse: bibleVerse,
                      autoScrollController: _autoScrollController(index),
                    ),
                  (CustomText customText) => CustomTextWidget(
                      customText: customText,
                      autoScrollController: _autoScrollController(index),
                    ),
                  (SongLyric songLyric) => SongLyricWidget(
                      songLyric: songLyric,
                      autoScrollController: _autoScrollController(index),
                    ),
                  _ => throw UnimplementedError(),
                };
              },
            ),
          ),
        ),
      ),
    );

    // FIXME: it must be wrapped, even when it is not song lyric, otherwise the pageview is initialized again and displayed content does not make sense
    return ExternalsWrapper(songLyric: _currentItem is SongLyric ? _currentItem as SongLyric : null, child: scaffold);
  }

  PreferredSizeWidget? _buildAppBar() {
    final presentationNotifier = ref.read(presentationProvider.notifier);

    return switch (_currentItem) {
      (BibleVerse bibleVerse) => AppBar(
          leading: const CustomBackButton(),
          title: Text(bibleVerse.name),
          actions: [
            Highlightable(
              onTap: () => _editBibleVerse(bibleVerse),
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              icon: const Icon(Icons.edit),
            ),
            Highlightable(
              onTap: () => presentationNotifier.isPresenting
                  ? presentationNotifier.stop()
                  : context.push('/display/present').then((_) => presentationNotifier.change(bibleVerse)),
              padding: const EdgeInsets.only(left: kDefaultPadding, right: 1.5 * kDefaultPadding),
              icon: Icon(ref.watch(presentationProvider.select((presentation) => presentation.isPresenting))
                  ? Icons.cancel_presentation
                  : Icons.cast),
            ),
          ],
        ),
      (CustomText customText) => AppBar(
          leading: const CustomBackButton(),
          title: Text(customText.name),
          actions: [
            Highlightable(
              onTap: () => _editCustomText(customText),
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              icon: const Icon(Icons.edit),
            ),
            Highlightable(
              onTap: () => presentationNotifier.isPresenting
                  ? presentationNotifier.stop()
                  : context.push('/display/present').then((_) => presentationNotifier.change(customText)),
              padding: const EdgeInsets.only(left: kDefaultPadding, right: 1.5 * kDefaultPadding),
              icon: Icon(ref.watch(presentationProvider.select((presentation) => presentation.isPresenting))
                  ? Icons.cancel_presentation
                  : Icons.cast),
            ),
          ],
        ),
      (SongLyric songLyric) => AppBar(
          title: Text('${songLyric.ezId}'),
          leading: const CustomBackButton(),
          actions: [
            StatefulBuilder(
              builder: (context, setState) => Highlightable(
                onTap: () => setState(() => ref.read(playlistsProvider.notifier).toggleFavorite(songLyric)),
                padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                icon: Icon(songLyric.isFavorite ? Icons.star : Icons.star_outline),
              ),
            ),
            Highlightable(
              onTap: () => showModalBottomSheet(
                context: context,
                builder: (context) => PlaylistsSheet(selectedSongLyric: songLyric),
              ),
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              icon: const Icon(Icons.playlist_add),
            ),
            SongLyricMenuButton(songLyric: songLyric),
          ],
        ),
      _ => throw UnimplementedError(),
    };
  }

  Widget? _buildBottomSheet() {
    final activePlayer = ref.watch(activePlayerProvider);
    final presentation = ref.watch(presentationProvider);
    final fullScreen = ref.watch(displayScreenStatusProvider.select((status) => status.fullScreen));

    Widget? bottomSheet;

    if (presentation.isPresenting) {
      bottomSheet = Row(children: [
        Highlightable(
          isEnabled: presentation.hasSongLyricsParser,
          onTap: presentation.prevVerse,
          // use arrow_back_ios_new, because arrow_back_ios is not centered
          icon: Icon(Theme.of(context).platform.isIos ? Icons.arrow_back_ios_new : Icons.arrow_back),
        ),
        Highlightable(
          onTap: presentation.togglePause,
          icon: Icon(presentation.isPaused ? Icons.play_arrow : Icons.pause),
        ),
        Highlightable(
          isEnabled: presentation.hasSongLyricsParser,
          onTap: presentation.nextVerse,
          icon: Icon(Icons.adaptive.arrow_forward),
        ),
        const Spacer(),
        Highlightable(
          isEnabled: presentation.hasSongLyricsParser,
          onTap: presentation.toggleVisibility,
          icon: Icon(presentation.isVisible ? Icons.visibility_off : Icons.visibility),
        ),
        Highlightable(
          onTap: () => showModalBottomSheet(
            context: context,
            builder: (context) => PresentationSettingsWidget(
              onExternalDisplay: !ref.read(presentationProvider).isPresentingLocally,
            ),
          ),
          icon: const Icon(Icons.tune),
        ),
        Highlightable(
          onTap: () => presentation.stop(),
          icon: const Icon(Icons.close),
        ),
      ]);
    } else if (activePlayer != null) {
      bottomSheet = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: ref.read(displayScreenStatusProvider.notifier).showExternals,
        child: CollapsedPlayer(
          controller: activePlayer,
          onDismiss: ref.read(activePlayerProvider.notifier).dismiss,
        ),
      );
    }

    if (bottomSheet != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5 * kDefaultPadding, vertical: kDefaultPadding) +
            EdgeInsets.only(bottom: fullScreen ? MediaQuery.paddingOf(context).bottom : 0),
        child: bottomSheet,
      );
    }

    return null;
  }

  void _itemChanged(int index) {
    setState(() => _currentIndex = index % _items.length);

    // notify presentation
    ref.read(presentationProvider.notifier).change(_currentItem);

    // change highlight index on tablet
    final selectedDisplayableItemArgumentsNotifier = SelectedDisplayableItemArguments.of(context);

    if (selectedDisplayableItemArgumentsNotifier != null) {
      selectedDisplayableItemArgumentsNotifier.value = DisplayScreenArguments(
        items: _items,
        initialIndex: _currentIndex,
      );
    }

    // saves item as recent if it was at least for 2 seconds on screen
    _addRecentItemTimer?.cancel();
    _addRecentItemTimer = Timer(
      const Duration(seconds: 2),
      () => ref.read(recentItemsProvider.notifier).add(_currentItem),
    );

    ref.read(activePlayerProvider.notifier).dismiss();
  }

  void _fontScaleStarted(ScaleStartDetails _) {
    _fontSizeScaleBeforeScale = ref.read(settingsProvider).fontSizeScale;
  }

  void _fontScaleUpdated(ScaleUpdateDetails details) {
    ref.read(settingsProvider.notifier).changeFontSizeScale(_fontSizeScaleBeforeScale * details.scale);
  }

  void _editBibleVerse(BibleVerse bibleVerse) async {
    final editedBibleVerse =
        (await context.push('/playlist/bible_verse/select_verse', arguments: bibleVerse)) as BibleVerse?;

    if (editedBibleVerse != null) {
      setState(() => _items[_currentIndex] = editedBibleVerse);
    }
  }

  void _editCustomText(CustomText customText) async {
    final editedCustomText = (await context.push('/playlist/custom_text/edit', arguments: customText)) as CustomText?;

    if (editedCustomText != null) {
      setState(() => _items[_currentIndex] = editedCustomText);
    }
  }
}
