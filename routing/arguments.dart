import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zpevnik/models/bible_verse.dart';
import 'package:zpevnik/models/custom_text.dart';
import 'package:zpevnik/models/model.dart';
import 'package:zpevnik/models/playlist.dart';
import 'package:zpevnik/models/song_lyric.dart';
import 'package:zpevnik/models/songbook.dart';

@immutable
class DisplayScreenArguments {
  final List<DisplayableItem> items;
  final int initialIndex;

  final bool showSearchScreen;

  final Playlist? playlist;
  final Songbook? songbook;

  const DisplayScreenArguments({
    required this.items,
    this.initialIndex = 0,
    this.showSearchScreen = false,
    this.playlist,
    this.songbook,
  });

  factory DisplayScreenArguments.bibleVerse(BibleVerse bibleVerse) {
    return DisplayScreenArguments(items: [bibleVerse]);
  }

  factory DisplayScreenArguments.customText(CustomText customText) {
    return DisplayScreenArguments(items: [customText]);
  }

  factory DisplayScreenArguments.songLyric(SongLyric songLyric, {bool showSearchScreen = false}) {
    return DisplayScreenArguments(items: [songLyric], showSearchScreen: showSearchScreen);
  }

  bool get canShowMenu => playlist != null || songbook != null || showSearchScreen;

  @override
  int get hashCode => Object.hash(runtimeType, items.length, initialIndex);

  @override
  bool operator ==(Object other) {
    return other is DisplayScreenArguments && initialIndex == other.initialIndex && items.length == other.items.length;
  }
}

@immutable
class SearchScreenArguments {
  final bool shouldReturnSongLyric;

  const SearchScreenArguments({required this.shouldReturnSongLyric});

  factory SearchScreenArguments.returnSongLyric() => const SearchScreenArguments(shouldReturnSongLyric: true);
}
