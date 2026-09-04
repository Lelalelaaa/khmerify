import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Please add Web credentials if you want to run on Web!');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Unsupported platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyALT7-zhNNjDKJJdirDciZ6JFVpSD1s9Eg',
    appId: '1:788507375310:android:7a11eb4812f473d460029f',
    messagingSenderId: '788507375310',
    projectId: 'khmerify-14086',
    storageBucket: 'khmerify-14086.firebasestorage.app',
  );
}
