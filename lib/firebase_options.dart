// File generated by FlutterFire CLI.
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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCAmNUqO4_e0PNCDKAiLL9VVfvJA0eB32A',
    appId: '1:641906560409:web:82d1291557c32fb6c7d708',
    messagingSenderId: '641906560409',
    projectId: 'wather-cast',
    authDomain: 'wather-cast.firebaseapp.com',
    storageBucket: 'wather-cast.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCspdqKRJcjjcNV8efmpMEnFoMtBQNMgzM',
    appId: '1:641906560409:android:844874fcacd5b2a0c7d708',
    messagingSenderId: '641906560409',
    projectId: 'wather-cast',
    storageBucket: 'wather-cast.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA7DMXTUlTabCYI4F7hW3iK4FLzGb5CKcM',
    appId: '1:641906560409:ios:e3b9747002882864c7d708',
    messagingSenderId: '641906560409',
    projectId: 'wather-cast',
    storageBucket: 'wather-cast.firebasestorage.app',
    iosBundleId: 'com.example.weatherCast',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA7DMXTUlTabCYI4F7hW3iK4FLzGb5CKcM',
    appId: '1:641906560409:ios:e3b9747002882864c7d708',
    messagingSenderId: '641906560409',
    projectId: 'wather-cast',
    storageBucket: 'wather-cast.firebasestorage.app',
    iosBundleId: 'com.example.weatherCast',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCAmNUqO4_e0PNCDKAiLL9VVfvJA0eB32A',
    appId: '1:641906560409:web:bf65952f13f184d2c7d708',
    messagingSenderId: '641906560409',
    projectId: 'wather-cast',
    authDomain: 'wather-cast.firebaseapp.com',
    storageBucket: 'wather-cast.firebasestorage.app',
  );
}
