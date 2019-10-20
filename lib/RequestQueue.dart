import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:hack_heroes_server/HelpRequest.dart';

class RequestQueue {
  RequestQueue();

  int enqueue(HelpRequest request) {
    _queue.addLast(request);

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
      return _queue.first;
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