import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// IMPORTANT: Replace these placeholder values with your actual Firebase configuration.
/// You can get these values from the Firebase Console:
/// 1. Go to https://console.firebase.google.com/
/// 2. Select your project (or create a new one)
/// 3. Click on the gear icon (Project settings)
/// 4. Under "Your apps", add your Flutter app or select existing one
/// 5. Copy the configuration values
///
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
    apiKey: 'AIzaSyB_xmOOgUoC5mnboUMKxLhKZqlgggw2wHs',
    appId: '1:534037293402:web:39cb85ad44b8e3a47e2b63',
    messagingSenderId: '534037293402',
    projectId: 'ytcom-6d117',
    authDomain: 'ytcom-6d117.firebaseapp.com',
    storageBucket: 'ytcom-6d117.firebasestorage.app',
    measurementId: 'G-28RZTP1FH5',
  );

  // TODO: Replace with your actual Firebase Web configuration

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA3-jNIVPx_ecTf7ljN5AmPCo1HyrEWqpQ',
    appId: '1:534037293402:android:37ab3e733a657af87e2b63',
    messagingSenderId: '534037293402',
    projectId: 'ytcom-6d117',
    storageBucket: 'ytcom-6d117.firebasestorage.app',
  );

  // TODO: Replace with your actual Firebase Android configuration

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCb9kRuQPexE0baQqRwSshiJN53fUv0j3g',
    appId: '1:534037293402:ios:ed50f93f73e0f0227e2b63',
    messagingSenderId: '534037293402',
    projectId: 'ytcom-6d117',
    storageBucket: 'ytcom-6d117.firebasestorage.app',
    iosBundleId: 'com.desa.swarawarga',
  );

  // TODO: Replace with your actual Firebase iOS configuration

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCb9kRuQPexE0baQqRwSshiJN53fUv0j3g',
    appId: '1:534037293402:ios:ed50f93f73e0f0227e2b63',
    messagingSenderId: '534037293402',
    projectId: 'ytcom-6d117',
    storageBucket: 'ytcom-6d117.firebasestorage.app',
    iosBundleId: 'com.desa.swarawarga',
  );

  // TODO: Replace with your actual Firebase macOS configuration

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB_xmOOgUoC5mnboUMKxLhKZqlgggw2wHs',
    appId: '1:534037293402:web:a04df0d7f6506a307e2b63',
    messagingSenderId: '534037293402',
    projectId: 'ytcom-6d117',
    authDomain: 'ytcom-6d117.firebaseapp.com',
    storageBucket: 'ytcom-6d117.firebasestorage.app',
    measurementId: 'G-E758HNJD76',
  );

  // TODO: Replace with your actual Firebase Windows configuration
}