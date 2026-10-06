// File generated for farmer-buyer-marketplace-9bd05
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return android;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD3PteAy-34H8erdwrACQI4F1xqHY3uL20',
    appId: '1:313633004963:android:db398af8c774b7a9dd0e16',
    messagingSenderId: '313633004963',
    projectId: 'farmer-buyer-marketplace-9bd05',
    storageBucket: 'farmer-buyer-marketplace-9bd05.firebasestorage.app',
  );
}
