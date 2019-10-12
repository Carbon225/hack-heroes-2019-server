import 'dart:async';

import 'dart:io';

class SessionRequest {
  SessionRequest(this._caller);

  void complete() {
    _stream.add(true);
  }

  Future<void> get peerFound {
    return _stream.stream.first;
  }

  get caller {
    return _caller;
  }

  final Socket _caller;
  Socket recipient;

  final _stream = StreamController<bool>();
}