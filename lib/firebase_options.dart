// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCSwZhahiDkdBW0CuzAbew54dqtJDw3Jqs',
    appId: '1:901745155949:web:2ad712551f77c614b3c464',
    messagingSenderId: '901745155949',
    projectId: 'grgplatform',
    authDomain: 'grgplatform.firebaseapp.com',
    storageBucket: 'grgplatform.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCf2zNovFnrKUkAGrZZw1-wVgcoqX2ZfOw',
    appId: '1:901745155949:android:11a6f1a289f1a74fb3c464',
    messagingSenderId: '901745155949',
    projectId: 'grgplatform',
    storageBucket: 'grgplatform.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBoLSq850AdPgBTWLCzCqs3QnHBb5ExEFQ',
    appId: '1:901745155949:ios:fa2fc4cf3d683ce8b3c464',
    messagingSenderId: '901745155949',
    projectId: 'grgplatform',
    storageBucket: 'grgplatform.appspot.com',
    iosClientId: '901745155949-7p2cjvcpbhvgptiene5b57opc50l701s.apps.googleusercontent.com',
    iosBundleId: 'com.example.playurFlutterPlugin',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBoLSq850AdPgBTWLCzCqs3QnHBb5ExEFQ',
    appId: '1:901745155949:ios:fa2fc4cf3d683ce8b3c464',
    messagingSenderId: '901745155949',
    projectId: 'grgplatform',
    storageBucket: 'grgplatform.appspot.com',
    iosClientId: '901745155949-7p2cjvcpbhvgptiene5b57opc50l701s.apps.googleusercontent.com',
    iosBundleId: 'com.example.playurFlutterPlugin',
  );
}
