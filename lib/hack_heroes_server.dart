import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:hack_heroes_server/packets.dart';
import 'package:hack_heroes_server/session_request.dart';

class AppServer {
  AppServer();

  Future<void> start(int port) async {
    _socketServer = await ServerSocket.bind(InternetAddress.anyIPv4, port);

    _socketServer.listen(
      _onConnection,
      onDone: _onDone,
      onError: _onError,
    );

    print('Listening on localhost:$port');
  }

  void _onConnection(Socket socket) async {
    print('New connection from ${socket.remoteAddress}');

    bool sendingImage = false;
    Socket peer;

    await for (var data in socket) {
      print('Received ${Packets.command(data)}');

      final Commands command = sendingImage ? Commands.image : Packets.command(data);

      switch (command) {
        case Commands.requestSession:
          final sessionRequest = SessionRequest(socket);
          _userQueue.add(sessionRequest);

          try {
            await sessionRequest.peerFound.timeout(Duration(seconds: 5));
          }
          on TimeoutException {
            print('Session request timed out');
            _userQueue.remove(sessionRequest);
            socket.add(Packets.sessionNotFound);
            break;
          }

          print('Session resolved (caller)');
          peer = sessionRequest.recipient;
          _userQueue.remove(sessionRequest);
          socket.add(Packets.sessionFound);
          break;

        case Commands.offerHelp:
          if (_userQueue.isNotEmpty) {
            socket.add(Packets.helpWanted);
          }
          else {
            socket.add(Packets.helpNotWanted);
          }
          break;

        case Commands.connectToPeer:
          if (_userQueue.isEmpty) {
            socket.add(Packets.helpNotWanted);
            break;
          }

          print('Session resolved (recipient)');
          _userQueue.first.recipient = socket;
          peer = _userQueue.first.caller;
          _userQueue.first.complete();
          socket.add(Packets.sessionFound);
          break;

        case Commands.text:
        case Commands.imageStart:
        case Commands.image:
          if (peer == null) {
            sendingImage = false;
            socket.add(Packets.sessionNotFound);
            break;
          }

          if (command == Commands.imageStart) {
            sendingImage = true;
          }
          else if (data.last == Commands.imageStop.index) {
            sendingImage = false;
          }
          print('${data.length} bytes from ${socket.hashCode} to ${peer.hashCode}');
          peer.add(data);
          break;

        case Commands.pipeTest:
          if (peer == null) {
            sendingImage = false;
            socket.add(Packets.sessionNotFound);
            break;
          }

          print('Pipe test from ${socket.hashCode} to ${peer.hashCode}');
          peer.add(data);
          break;

        default:
          print('Unknown command');
      }
    }
  }

  void _onDone() {
    print('onDone');
  }

  void _onError(error, StackTrace trace) {
    print(error);
  }

  final _userQueue = Queue<SessionRequest>();

  ServerSocket _socketServer;
}