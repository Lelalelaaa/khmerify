import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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

  LibraryWord copyWith({String? romanized, String? khmer}) {
    return LibraryWord(
      romanized: romanized ?? this.romanized,
      khmer: khmer ?? this.khmer,
      aliases: aliases,
    );
  }
}

class AppData {
  static final history = ValueNotifier<List<HistoryEntry>>([]);
  static final library = ValueNotifier<List<LibraryWord>>([]);

  static Future<void> initialize() async {
    final json = await rootBundle.loadString(
      'assets/common_words_with_romanization.json',
    );
    final entries = jsonDecode(json) as List<dynamic>;
    library.value = entries
        .map((entry) {
          final item = entry as Map<String, dynamic>;
          return LibraryWord(
            romanized: item['romanized'] as String,
            khmer: item['khmer'] as String,
            aliases: (item['aliases'] as List<dynamic>? ?? [])
                .map((alias) => alias as String)
                .toList(),
          );
        })
        .toList(growable: true);
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

  static void addWord(LibraryWord word) {
    library.value = [...library.value, word];
  }

  static void updateWord(int index, LibraryWord word) {
    final words = [...library.value];
    words[index] = word;
    library.value = words;
  }

  static void deleteWord(int index) {
    final words = [...library.value]..removeAt(index);
    library.value = words;
  }
}
