import 'dart:convert';
import 'package:http/http.dart' as http;

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

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
  static Future<String> convert(String input) async {
    final response = await http.post(
      Uri.parse("$baseUrl/convert"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"input": input}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["output"];
    } else {
      throw Exception("Failed to convert: ${response.statusCode}");
    }
  }

  /// Return up to 3 fuzzy-matched spelling suggestions for [input].
  /// Returns an empty list on any error so callers can degrade gracefully.
  static Future<List<String>> getSuggestions(String input) async {
    try {
      final uri = Uri.parse("$baseUrl/suggest")
          .replace(queryParameters: {"q": input});
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return List<String>.from(data["suggestions"] as List);
      }
    } catch (_) {
      // Network unavailable — silently degrade
    }
    return [];
  }

  /// Tell the backend that the user dismissed a suggestion so it won't appear again.
  static Future<void> rejectSuggestion(String roman) async {
    try {
      await http.post(
        Uri.parse("$baseUrl/suggest/reject"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"roman": roman}),
      );
    } catch (_) {
      // Best-effort; ignore errors
    }
  }

  /// Submit a user-confirmed romanisation → Khmer mapping to the dictionary.
  static Future<void> submitWord(String roman, String khmer) async {
    final response = await http.post(
      Uri.parse("$baseUrl/words"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"roman": roman, "khmer": khmer}),
    );
    if (response.statusCode != 201) {
      throw Exception("Failed to submit word: ${response.statusCode}");
    }
  }
}