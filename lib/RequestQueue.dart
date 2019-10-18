import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:hack_heroes_server/HelpRequest.dart';

class RequestQueue {
  RequestQueue();

  int enqueue(HelpRequest request) {
    _queue.addLast(request);

    // remove request if client hasn't connected WS
    Future.delayed(Duration(seconds: 1), () {
      if (request.socket == null) {
        print('Client did not connect WS');
        removeID(request.id);
      }
    });

    // remove old sessions
    Future.delayed(Duration(minutes: 10), () {
      print('Removed old request');
      removeID(request.id);
    });

    return _queue.length;
  }

  HelpRequest dequeue() {
    if (_queue.isNotEmpty) {
      return _queue.removeFirst();
    }
    else {
      return null;
    }
  }

  HelpRequest get first {
    try {
      return _queue.firstWhere((e) => e.socket != null);
    }
    on StateError {
      return null;
    }
  }

  int get length {
    return _queue.length;
  }

  HelpRequest getRequest(String id) {
    try {
      return _queue.firstWhere((e) => e.id == id);
    }
    on StateError {
      return null;
    }
  }

  void assignSocket(String id, WebSocket socket) {
    final request = _queue.firstWhere((e) => e.id == id);
    request.socket = socket;
  }

  void removeID(String id) {
    _queue.removeWhere((e) => e.id == id);
  }

  static String generateID() {
    final values = List<int>.generate(IDSize, (i) => _random.nextInt(256));
    return base64Encode(values);
  }

  final _queue = Queue<HelpRequest>();

  static const IDSize = 32;
  static final _random = Random.secure();
}