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
    apiKey: 'AIzaSyDb6cWYIo2c01THv6P9uleUmFQQKyu_7AU',
    appId: '1:544710650542:web:0efdd4c160499ff9f39b3f',
    messagingSenderId: '544710650542',
    projectId: 'final-2d112',
    authDomain: 'final-2d112.firebaseapp.com',
    storageBucket: 'final-2d112.firebasestorage.app',
    measurementId: 'G-MLB42DXQDF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDWqpbt_XkDnodgisiDQYGZ_LEKN_oGFjc',
    appId: '1:544710650542:android:00076a4f682beacff39b3f',
    messagingSenderId: '544710650542',
    projectId: 'final-2d112',
    storageBucket: 'final-2d112.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBEo3eRvxPzIrxAes0R8uHzzzSA6iYY6Pk',
    appId: '1:544710650542:ios:8d7f2dc7b5b853bdf39b3f',
    messagingSenderId: '544710650542',
    projectId: 'final-2d112',
    storageBucket: 'final-2d112.firebasestorage.app',
    iosBundleId: 'com.example.fintech',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBEo3eRvxPzIrxAes0R8uHzzzSA6iYY6Pk',
    appId: '1:544710650542:ios:8d7f2dc7b5b853bdf39b3f',
    messagingSenderId: '544710650542',
    projectId: 'final-2d112',
    storageBucket: 'final-2d112.firebasestorage.app',
    iosBundleId: 'com.example.fintech',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDb6cWYIo2c01THv6P9uleUmFQQKyu_7AU',
    appId: '1:544710650542:web:41c758195396a305f39b3f',
    messagingSenderId: '544710650542',
    projectId: 'final-2d112',
    authDomain: 'final-2d112.firebaseapp.com',
    storageBucket: 'final-2d112.firebasestorage.app',
    measurementId: 'G-Q59RJXXSZJ',
  );

}