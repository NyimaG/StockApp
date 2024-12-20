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
    apiKey: 'AIzaSyDJRiU-bjHjUQG_R3tisXrFZYPX602nRqU',
    appId: '1:303961748797:web:3e5b5d120a85dc5427c154',
    messagingSenderId: '303961748797',
    projectId: 'stockapp-c95fd',
    authDomain: 'stockapp-c95fd.firebaseapp.com',
    storageBucket: 'stockapp-c95fd.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBbKc5hB0WMdZZ0zFrl2Jva6MYXRQAC8os',
    appId: '1:303961748797:android:ef3eccdc2c2c0b3627c154',
    messagingSenderId: '303961748797',
    projectId: 'stockapp-c95fd',
    storageBucket: 'stockapp-c95fd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyChDVEFkHZ5SPzSpc1h53nrkdF2uY_KFHw',
    appId: '1:303961748797:ios:fe78b0e81bc9981527c154',
    messagingSenderId: '303961748797',
    projectId: 'stockapp-c95fd',
    storageBucket: 'stockapp-c95fd.firebasestorage.app',
    iosBundleId: 'com.example.stockapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyChDVEFkHZ5SPzSpc1h53nrkdF2uY_KFHw',
    appId: '1:303961748797:ios:fe78b0e81bc9981527c154',
    messagingSenderId: '303961748797',
    projectId: 'stockapp-c95fd',
    storageBucket: 'stockapp-c95fd.firebasestorage.app',
    iosBundleId: 'com.example.stockapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDJRiU-bjHjUQG_R3tisXrFZYPX602nRqU',
    appId: '1:303961748797:web:0d8b238d6455316427c154',
    messagingSenderId: '303961748797',
    projectId: 'stockapp-c95fd',
    authDomain: 'stockapp-c95fd.firebaseapp.com',
    storageBucket: 'stockapp-c95fd.firebasestorage.app',
  );
}
