import 'dart:convert';

import 'package:http/http.dart' as http;

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

import 'device_identity.dart';

class WordCandidate {
  final String khmer;
  final String? gloss;
  final int weight;

  const WordCandidate({required this.khmer, this.gloss, required this.weight});

  factory WordCandidate.fromJson(Map<String, dynamic> json) {
    return WordCandidate(
      khmer: json['khmer'] as String,
      gloss: json['gloss'] as String?,
      weight: (json['weight'] as num?)?.toInt() ?? 1,
    );
  }
}

class WordSuggestion {
  final String romanized;
  final List<WordCandidate> options;

  const WordSuggestion({required this.romanized, required this.options});

  factory WordSuggestion.fromJson(Map<String, dynamic> json) {
    return WordSuggestion(
      romanized: json['romanized'] as String,
      options: (json['options'] as List<dynamic>)
          .map((item) => WordCandidate.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WordResult {
  final String input;
  final bool found;
  final List<WordCandidate> candidates;
  final WordSuggestion? suggestion;
  final String? patternFallback;

  const WordResult({
    required this.input,
    required this.found,
    required this.candidates,
    required this.suggestion,
    required this.patternFallback,
  });

  factory WordResult.fromJson(Map<String, dynamic> json) {
    return WordResult(
      input: json['input'] as String,
      found: json['found'] as bool,
      candidates: (json['candidates'] as List<dynamic>)
          .map((item) => WordCandidate.fromJson(item as Map<String, dynamic>))
          .toList(),
      suggestion: json['suggestion'] == null
          ? null
          : WordSuggestion.fromJson(json['suggestion'] as Map<String, dynamic>),
      patternFallback: json['pattern_fallback'] as String?,
    );
  }
}

class ApiService {
  // Use a dynamic getter to choose the correct localhost IP
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000"; // Web
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:8000"; // Android Emulator
    } else {
      return "http://127.0.0.1:8000"; // Fallback
    }
  }

  /// Convert romanised Khmer text to Khmer script.
  static Future<List<WordResult>> convert(String input) async {
    final userId = await DeviceIdentity.getOrCreate();
    final response = await http.post(
      Uri.parse("$baseUrl/convert"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"input": input, "user_id": userId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['results'] as List<dynamic>)
          .map((item) => WordResult.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception("Failed to convert: ${response.statusCode}");
    }
  }

  static Future<void> addWord(
    String romanized,
    String khmer, {
    String gloss = '',
    String source = 'user',
  }) async {
    final userId = await DeviceIdentity.getOrCreate();
    final response = await http.post(
      Uri.parse("$baseUrl/words"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "romanized": romanized,
        "khmer": khmer,
        "gloss": gloss,
        "source": source,
        "added_by": userId,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to submit word: ${response.statusCode}");
    }
  }

  static Future<void> confirmAlias(
    String newSpelling,
    String khmer, {
    String gloss = '',
  }) async {
    final userId = await DeviceIdentity.getOrCreate();
    final response = await http.post(
      Uri.parse("$baseUrl/words/confirm-alias"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "new_spelling": newSpelling,
        "khmer": khmer,
        "gloss": gloss,
        "added_by": userId,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to confirm alias: ${response.statusCode}");
    }
  }

  static Future<void> rejectSuggestion(
    String inputWord,
    String suggestedWord,
  ) async {
    final userId = await DeviceIdentity.getOrCreate();
    final response = await http.post(
      Uri.parse("$baseUrl/words/reject-suggestion"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "input_word": inputWord,
        "suggested_word": suggestedWord,
        "user_id": userId,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to reject suggestion: ${response.statusCode}");
    }
  }
}
