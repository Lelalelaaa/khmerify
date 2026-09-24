import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class KeyboardService {
  static const MethodChannel _channel =
      MethodChannel('com.example.khmerify/keyboard');

  /// Only Android supports the custom InputMethodService directly
  static bool get isPlatformSupported => !kIsWeb && Platform.isAndroid;

  /// Open Android system settings to enable the Khmerify Keyboard
  static Future<bool> openKeyboardSettings() async {
    if (!isPlatformSupported) return false;
    try {
      final result = await _channel.invokeMethod<bool>('openKeyboardSettings');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error opening keyboard settings: $e');
      return false;
    }
  }

  /// Check if the Khmerify Keyboard is toggled ON in system settings
  static Future<bool> isKeyboardEnabled() async {
    if (!isPlatformSupported) return false;
    try {
      final result = await _channel.invokeMethod<bool>('isKeyboardEnabled');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error checking keyboard status: $e');
      return false;
    }
  }

  /// Open the system IME switcher dialog (to switch to Khmerify Keyboard)
  static Future<bool> showKeyboardPicker() async {
    if (!isPlatformSupported) return false;
    try {
      final result = await _channel.invokeMethod<bool>('showKeyboardPicker');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error showing keyboard picker: $e');
      return false;
    }
  }
}
