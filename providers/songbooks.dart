import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zpevnik/models/objectbox.g.dart';
import 'package:zpevnik/models/songbook.dart';
import 'package:zpevnik/providers/app_dependencies.dart';
import 'package:zpevnik/providers/utils.dart';

part 'songbooks.g.dart';

const _pinnedSongbookIdsKey = 'pinned_songbook_ids';

// TODO: remove this after some time, that all users have at least 3.1.0 version
void migratePinnedSongbooks(Store store, SharedPreferences sharedPreferences) {
  final query = store.box<Songbook>().query(Songbook_.isPinned.equals(true)).build();
  final pinnedSongbookIds = query.findIds();

  query.close();

  if (pinnedSongbookIds.isNotEmpty) {
    sharedPreferences.setStringList(_pinnedSongbookIdsKey, [for (final id in pinnedSongbookIds) '$id']);
  }
}

@riverpod
class PinnedSongbookIds extends _$PinnedSongbookIds {
  SharedPreferences get _sharedPreferences {
    return ref.read(appDependenciesProvider).sharedPreferences;
  }

  @override
  Set<int> build() {
    return {for (final id in _sharedPreferences.getStringList(_pinnedSongbookIdsKey) ?? []) int.parse(id)};
  }

  void togglePin(Songbook songbook) {
    if (state.contains(songbook.id)) {
      state = {
        for (final id in state)
          if (id != songbook.id) id
      };
    } else {
      state = {songbook.id, ...state};
    }

    _sharedPreferences.setStringList(_pinnedSongbookIdsKey, [for (final id in state) '$id']);
  }
}

@riverpod
List<Songbook> songbooks(SongbooksRef ref) {
  final songbooks = queryStore(ref, condition: Songbook_.isPrivate.equals(false));
  final pinnedSongbookIds = ref.watch(pinnedSongbookIdsProvider);

  songbooks.sort((a, b) {
    if (pinnedSongbookIds.contains(a.id) && pinnedSongbookIds.contains(b.id)) {
      return a.compareTo(b);
    } else if (pinnedSongbookIds.contains(a.id)) {
      return -1;
    } else if (pinnedSongbookIds.contains(b.id)) {
      return 1;
    } else {
      return a.compareTo(b);
    }
  });

  return songbooks;
}
