import 'package:hack_heroes_server/hack_heroes_server.dart';

main(List<String> arguments) {
  final server  = AppServer();
  server.start(9090);
}
