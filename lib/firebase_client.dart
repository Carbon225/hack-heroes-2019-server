import 'package:fcm_push/fcm_push.dart';
import 'package:hack_heroes_server/firebase_token.dart';

class FirebaseClient {
  FirebaseClient()
  : _fcm = FCM(getFirebaseToken());

  Future<void> broadcast(String topic, String title, String body) async {
    final message = Message()
      ..to = topic
      ..title = title
      ..body = body;

    try {
      await _fcm.send(message);
    }
    on FormatException {
      // the library simply doesn't work correctly
      // it publishes the message but fails when parsing the response
      // so we ignore this error
    }
  }

  final FCM _fcm;
}