# Unofficial Firestore API

This project tries to create a plattform independend API in Dart for Cloud Firestore.
It's is almost source compatible with the flutter version of the library [https://pub.dev/packages/cloud_firestore] and matches the source of the web version as much as possible [https://pub.dev/packages/firebase_web]

## Setup

For each plattform there is currently a wrapper that implements this API. We hope that one day we will have
direct support for this API in the libraries. The wrapper only wraps the plattform specific Firestore object, so that you have to initialize Firebase on your plattform yourself.

On Flutter this is really as simple as calling the FirestoreImpl wrapper.

```dart

import 'package:firestore_api/firestore_api.dart';
import 'package:firestore_flutter/firestore_flutter.dart';

main() {
    Firestore firestore = FirestoreImpl.instance;
    // from here on you can use the API
}

```

On web you have to initialize the Firebase library first and then use the Firestore part in the wrapper.

```dart

import 'package:firebase/firebase.dart';
import 'package:firestore_api/firestore_api.dart';
import 'package:firestore_web/firestore_web.dart';

main() {
    App app = initializeApp(
        apiKey: ...,
        authDomain: ...,
        databaseURL: ...,
        projectId: ...,
        storageBucket: ...,
        messagingSenderId: ...);

    Firebase firebase = FirebaseImpl(app.firestore());
    // from here on you can use the API
}
