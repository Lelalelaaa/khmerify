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
}