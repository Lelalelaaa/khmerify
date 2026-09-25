import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryEntry {
  final String romanizedText;
  final String khmerText;
  final DateTime createdAt;

  const HistoryEntry({
    required this.romanizedText,
    required this.khmerText,
    required this.createdAt,
  });
}

class LibraryWord {
  final String romanized;
  final String khmer;
  final List<String> aliases;

  const LibraryWord({
    required this.romanized,
    required this.khmer,
    this.aliases = const [],
  });

  factory LibraryWord.fromJson(Map<String, dynamic> json) {
    return LibraryWord(
      romanized: json['romanized'] as String,
      khmer: json['khmer'] as String,
      aliases: (json['aliases'] as List<dynamic>? ?? [])
          .map((alias) => alias as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'romanized': romanized,
    'khmer': khmer,
    'aliases': aliases,
  };

  LibraryWord copyWith({String? romanized, String? khmer}) {
    return LibraryWord(
      romanized: romanized ?? this.romanized,
      khmer: khmer ?? this.khmer,
      aliases: aliases,
    );
  }
}

class AppData {
  static const _libraryStorageKey = 'khmerify_library';
  static final history = ValueNotifier<List<HistoryEntry>>([]);
  static final library = ValueNotifier<List<LibraryWord>>([]);

  static Future<void> initialize() async {
    final json = await rootBundle.loadString(
      'assets/common_words_with_romanization.json',
    );
    final entries = jsonDecode(json) as List<dynamic>;
    final seedLibrary = entries
        .map((entry) => LibraryWord.fromJson(entry as Map<String, dynamic>))
        .toList(growable: true);

    final preferences = await SharedPreferences.getInstance();
    final savedLibrary = preferences.getString(_libraryStorageKey);
    if (savedLibrary == null) {
      library.value = seedLibrary;
      return;
    }

    try {
      final decoded = jsonDecode(savedLibrary) as List<dynamic>;
      library.value = decoded
          .map((entry) => LibraryWord.fromJson(entry as Map<String, dynamic>))
          .toList(growable: true);
    } catch (_) {
      library.value = seedLibrary;
    }
  }

  static void addHistory({required String romanized, required String khmer}) {
    history.value = [
      HistoryEntry(
        romanizedText: romanized,
        khmerText: khmer,
        createdAt: DateTime.now(),
      ),
      ...history.value,
    ];
  }

  static Future<void> _persistLibrary() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _libraryStorageKey,
      jsonEncode(library.value.map((word) => word.toJson()).toList()),
    );
  }

  static Future<void> addWord(LibraryWord word) async {
    library.value = [...library.value, word];
    await _persistLibrary();
  }

  static Future<void> updateWord(int index, LibraryWord word) async {
    final words = [...library.value];
    words[index] = word;
    library.value = words;
    await _persistLibrary();
  }

  static Future<void> deleteWord(int index) async {
    final words = [...library.value]..removeAt(index);
    library.value = words;
    await _persistLibrary();
  }
}
