import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not configured for this project.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS is not configured for this project.');
      case TargetPlatform.windows:
        throw UnsupportedError('Windows is not configured for this project.');
      case TargetPlatform.linux:
        throw UnsupportedError('Linux is not configured for this project.');
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAXJBXLGIHSpDXwd_q4gk-QsKp6Hf-L9gA',
    appId: '1:542607824855:android:9cf0bd880a7fbb5043dd92',
    messagingSenderId: '542607824855',
    projectId: 'fitness-154e6',
    storageBucket: 'fitness-154e6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDFFmJVpZw81wSQE21sBTNGcoFOC1sEW40',
    appId: '1:542607824855:ios:db198010b61df62d43dd92',
    messagingSenderId: '542607824855',
    projectId: 'fitness-154e6',
    storageBucket: 'fitness-154e6.firebasestorage.app',
    iosBundleId: 'com.speechmaster.speechCoach',
  );
}
