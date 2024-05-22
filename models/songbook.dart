import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:objectbox/objectbox.dart';
import 'package:zpevnik/models/model.dart';
import 'package:zpevnik/models/songbook_record.dart';
import 'package:zpevnik/models/tag.dart';

part 'songbook.freezed.dart';
part 'songbook.g.dart';

// prioritized songbook shortcuts in sorting
const prioritized = {'H1': 0, 'H2': 1, 'K': 2, 'Kan': 3};

// offset for songbook tags, tags from API have id > 0, language tags have negative id starting from -1, so offset -1000 should be enough
const _songbookIdOffset = -1000;

@Freezed(toJson: false, equal: false)
class Songbook with _$Songbook implements Comparable<Songbook>, Identifiable, SongsList, RecentItem {
  static const String fieldKey = 'songbooks';

  const Songbook._();

  @Entity(realClass: Songbook)
  @JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
  const factory Songbook({
    @Id(assignable: true) @JsonKey(fromJson: int.parse) required int id,
    required String name,
    @JsonKey(defaultValue: '') required String shortcut,
    String? color,
    String? colorText,
    required bool isPrivate,
    @Deprecated('is handled independently on model') bool? isPinned,
    @Backlink() @JsonKey(fromJson: _songbookRecordsFromJson) required ToMany<SongbookRecord> records,
  }) = _Songbook;

  factory Songbook.fromJson(Map<String, Object?> json) => _$SongbookFromJson(json);

  Tag get tag => Tag(
        id: id + _songbookIdOffset,
        name: name,
        dbType: TagType.songbook.rawValue,
        songLyricsCount: records.length,
      );

  @override
  int compareTo(Songbook other) {
    if (prioritized.containsKey(shortcut) && prioritized.containsKey(other.shortcut)) {
      return prioritized[shortcut]!.compareTo(prioritized[other.shortcut]!);
    } else if (prioritized.containsKey(shortcut)) {
      return -1;
    } else if (prioritized.containsKey(other.shortcut)) {
      return 1;
    }

    return name.compareTo(other.name);
  }

  @override
  RecentItemType get recentItemType => RecentItemType.songbook;

  @override
  int get hashCode => id;

  @override
  bool operator ==(Object other) => other is Songbook && id == other.id;
}

ToMany<SongbookRecord> _songbookRecordsFromJson(List<dynamic>? jsonList) => ToMany();
