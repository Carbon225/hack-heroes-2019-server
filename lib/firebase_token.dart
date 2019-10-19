import 'dart:io';

String getFirebaseToken() {
  return File('/run/secrets/firebase_token').readAsStringSync();
}