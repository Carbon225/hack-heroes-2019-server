import 'dart:io';

import 'package:hack_heroes_server/RequestQueue.dart';

class HelpRequest {
  HelpRequest(this.text, this.image, [String id])
  : this.id = id ?? RequestQueue.generateID();

  final String text;
  final String image;
  final String id;
}