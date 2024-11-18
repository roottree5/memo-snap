// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAbiN9JFr7-UsJGv0_OeUEFP7SzCszY5sA',
    appId: '1:315782856347:web:b5543125de7ff3bdc50e02',
    messagingSenderId: '315782856347',
    projectId: 'aimemosnap',
    authDomain: 'aimemosnap.firebaseapp.com',
    storageBucket: 'aimemosnap.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDtgTqhgwCyPP5_k_XdPeNcFk06IkZG_WA',
    appId: '1:315782856347:android:7787c75d4cf7e04fc50e02',
    messagingSenderId: '315782856347',
    projectId: 'aimemosnap',
    storageBucket: 'aimemosnap.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA8IKsxOCEXxI703vktFr8oJr-d9osuox4',
    appId: '1:315782856347:ios:71aab40c5b964d84c50e02',
    messagingSenderId: '315782856347',
    projectId: 'aimemosnap',
    storageBucket: 'aimemosnap.appspot.com',
    iosClientId: '315782856347-u3o51e3rnnr9cbt7cclgagbkh4ki8hg2.apps.googleusercontent.com',
    iosBundleId: 'com.example.aimemosnap',
  );
}