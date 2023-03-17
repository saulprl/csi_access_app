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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBj8t_E4V_kr1Rp8sW8epdbsTjLvAcHnyM',
    appId: '1:1050055617140:android:582c43d3c7e97819347f21',
    messagingSenderId: '1050055617140',
    projectId: 'csi-door',
    databaseURL: 'https://csi-door-default-rtdb.firebaseio.com',
    storageBucket: 'csi-door.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDiHGSKhkPQ92Rpu_tA6w74dEis9GbMrSU',
    appId: '1:1050055617140:ios:47cea8065a203052347f21',
    messagingSenderId: '1050055617140',
    projectId: 'csi-door',
    databaseURL: 'https://csi-door-default-rtdb.firebaseio.com',
    storageBucket: 'csi-door.appspot.com',
    iosClientId: '1050055617140-mtp40rrooe0qiv0f1t87jt3lpn5c8vc2.apps.googleusercontent.com',
    iosBundleId: 'com.example.csiDoorLogs',
  );
}
