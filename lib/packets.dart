/* Packet structure

 0    - command
 1-n  - data

 */

import 'dart:convert';

enum Commands {
  requestSession,
  sessionFound,
  sessionNotFound,
  text,
  offerHelp,
  helpWanted,
  helpNotWanted,
  connectToPeer,
  pipeTest,
}

class Packets {

  static final List<int> sessionFound = [
    Commands.sessionFound.index,
  ];

  static final List<int> sessionNotFound = [
    Commands.sessionNotFound.index,
  ];

  static final List<int> helpWanted = [
    Commands.helpWanted.index,
  ];

  static final List<int> helpNotWanted = [
    Commands.helpNotWanted.index,
  ];

  static Commands command(List<int> packet) {
    return Commands.values[packet[0]];
  }
}