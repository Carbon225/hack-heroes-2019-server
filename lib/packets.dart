/* Packet structure

 0    - command
 1-n  - data

 */

import 'dart:convert';

enum Commands {
  requestSession,
  sessionFound,
  sessionNotAvailable,
  text,
}

class Packets {

  static final List<int> requestSession = [
    Commands.requestSession.index,
  ];

  static final List<int> sessionFound = [
    Commands.sessionFound.index,
  ];

  static List<int> sendText(String msg) {
    final packet = [Commands.text.index];
    packet.addAll(utf8.encode(msg));
    return packet;
  }

  static Commands command(List<int> packet) {
    return Commands.values[packet[0]];
  }
}