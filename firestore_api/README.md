# Unofficial Firestore API

This project tries to create a plattform independend API in Dart for Cloud Firestore.
It's is almost source compatible with the flutter version of the library [https://pub.dev/packages/cloud_firestore] and matches the source of the web version as much as possible [https://pub.dev/packages/firebase_web]

## Setup

For each plattform there is currently a wrapper implementation that implements this API. The wrapper
only wraps the plattform specific Firestore object, so that you have to initialize Firebase on your
plattform yourself.

For example on Android:

```dart

import 'package:firestore_api/firestore_api.dart';
import 'package:firestore_flutter/firestore_flutter.dart';

main() {
    Firestore firestore = FirestoreImpl.instance;
    // from here on you can use the API
}

```