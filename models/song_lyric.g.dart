// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_lyric.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SongLyricImpl _$$SongLyricImplFromJson(Map<String, dynamic> json) =>
    _$SongLyricImpl(
      id: int.parse(json['id'] as String),
      ezId: (_readEzId(json, 'ez_id') as num).toInt(),
      name: json['name'] as String,
      secondaryName1: json['secondary_name_1'] as String?,
      secondaryName2: json['secondary_name_2'] as String?,
      lyrics: json['lyrics'] as String?,
      lilypond: json['lilypond_svg'] as String?,
      externalRenderedScores: _externalRenderedScoresFromJson(
          json['external_rendered_scores'] as List),
      hymnology: json['hymnology'] as String,
      lang: json['lang'] as String,
      langDescription: json['lang_string'] as String,
      dbType: SongLyricType.rawValueFromString(json['type_enum'] as String?),
      hasChords: json['has_chords'] as bool,
      accidentals: (json['accidentals'] as num?)?.toInt(),
      showChords: json['show_chords'] as bool?,
      transposition: (json['transposition'] as num?)?.toInt(),
      song: _songFromJson(json['song'] as Map<String, dynamic>?),
      settings: _settingsFromJson(json['settings'] as Map<String, dynamic>?),
      authors: _authorsFromJson(json['authors_pivot'] as List),
      tags: _tagsFromJson(json['tags'] as List),
      externals: _externalsFromJson(json['externals'] as List),
      songbookRecords:
          _songbookRecordsFromJson(json['songbook_records'] as List),
      playlistRecords:
          _playlistRecordsFromJson(json['playlist_records'] as List?),
    );
