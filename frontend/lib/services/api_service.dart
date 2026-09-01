import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this later if you host the backend somewhere other than local
  static const String baseUrl = "http://127.0.0.1:8000";

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