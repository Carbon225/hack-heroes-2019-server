import 'dart:convert';
import 'dart:io';

import 'package:hack_heroes_server/packets.dart';

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

  int _count = 0;

  void _onConnection(Socket socket) async {
    print('New connection from ${socket.remoteAddress}');

    await for (var data in socket) {
      print('Received $data');

      switch (Packets.command(data)) {
        case Commands.requestSession:
          socket.add(Packets.sessionFound);
          break;

        case Commands.text:
          print(utf8.decode(data.sublist(1)));
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

  ServerSocket _socketServer;
}