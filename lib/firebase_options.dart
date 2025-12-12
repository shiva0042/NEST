// Firebase configuration for NEST App
// Auto-generated from google-services.json

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  // Android Configuration (from google-services.json)
  // Android Configuration (from google-services.json)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDs1mDeSf0JuL9MS7jftf1SeskttscGPUI',
    appId: '1:508456724410:android:24abeb998d15678af91f83',
    messagingSenderId: '508456724410',
    projectId: 'nest-db923',
    storageBucket: 'nest-db923.firebasestorage.app',
  );

  // Web Configuration - NEST Web App
  // Registered in Firebase Console: https://console.firebase.google.com/project/nest-db923
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDs1mDeSf0JuL9MS7jftf1SeskttscGPUI',
    appId: '1:508456724410:web:c9cb27590e97472ff91f83',
    messagingSenderId: '508456724410',
    projectId: 'nest-db923',
    authDomain: 'nest-db923.firebaseapp.com',
    storageBucket: 'nest-db923.firebasestorage.app',
  );

  // iOS Configuration
  // TODO: Add iOS app in Firebase Console to get these values
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB8Jfwm8SDJzPJt-u4S1bLEuvC-BRFVyp4',
    appId: '1:956594217906:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '956594217906',
    projectId: 'nest-app-251b1',
    storageBucket: 'nest-app-251b1.firebasestorage.app',
    iosBundleId: 'com.example.nearBasket',
  );

  // macOS Configuration
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB8Jfwm8SDJzPJt-u4S1bLEuvC-BRFVyp4',
    appId: '1:956594217906:ios:YOUR_MACOS_APP_ID',
    messagingSenderId: '956594217906',
    projectId: 'nest-app-251b1',
    storageBucket: 'nest-app-251b1.firebasestorage.app',
    iosBundleId: 'com.example.nearBasket',
  );

  // Windows Configuration
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB8Jfwm8SDJzPJt-u4S1bLEuvC-BRFVyp4',
    appId: '1:956594217906:web:YOUR_WINDOWS_APP_ID',
    messagingSenderId: '956594217906',
    projectId: 'nest-app-251b1',
    authDomain: 'nest-app-251b1.firebaseapp.com',
    storageBucket: 'nest-app-251b1.firebasestorage.app',
  );
}
