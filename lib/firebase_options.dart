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
    apiKey: 'AIzaSyDEBG2b2cTSq-2tuvdtCeCALRP_qlzwj94',
    appId: '1:69682297411:web:eb18dad684350734f6f2f6',
    messagingSenderId: '69682297411',
    projectId: 'expense-tracker-11123',
    authDomain: 'expense-tracker-11123.firebaseapp.com',
    storageBucket: 'expense-tracker-11123.firebasestorage.app',
    measurementId: 'G-BXZK7EEC21',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBGWvpSVnTnBJzLYIhxRrz8VrgB7q-Er6o',
    appId: '1:69682297411:android:ef0e28101699ca0cf6f2f6',
    messagingSenderId: '69682297411',
    projectId: 'expense-tracker-11123',
    storageBucket: 'expense-tracker-11123.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCY4SW-B5Z7DaY_eevKKEq8uCZUmui7UoE',
    appId: '1:69682297411:ios:681fc4fb2f6869e9f6f2f6',
    messagingSenderId: '69682297411',
    projectId: 'expense-tracker-11123',
    storageBucket: 'expense-tracker-11123.firebasestorage.app',
    iosBundleId: 'com.example.expenseTracker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCY4SW-B5Z7DaY_eevKKEq8uCZUmui7UoE',
    appId: '1:69682297411:ios:681fc4fb2f6869e9f6f2f6',
    messagingSenderId: '69682297411',
    projectId: 'expense-tracker-11123',
    storageBucket: 'expense-tracker-11123.firebasestorage.app',
    iosBundleId: 'com.example.expenseTracker',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDEBG2b2cTSq-2tuvdtCeCALRP_qlzwj94',
    appId: '1:69682297411:web:5860e5d483709fe4f6f2f6',
    messagingSenderId: '69682297411',
    projectId: 'expense-tracker-11123',
    authDomain: 'expense-tracker-11123.firebaseapp.com',
    storageBucket: 'expense-tracker-11123.firebasestorage.app',
    measurementId: 'G-F4M3Z9LCHD',
  );

}