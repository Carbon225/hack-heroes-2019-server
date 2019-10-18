import 'dart:convert';
import 'dart:io';

class AppServer {
  AppServer();

  static const GetHelpEndpoint = '/getHelp';
  static const OfferHelpEndpoint = '/offerHelp';

  Future<void> start(int port) async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    server.listen(
      _onRequest,
      onDone: _onDone,
      onError: _onError,
    );

    print('Server started on localhost:$port');
  }

  Future<void> _onRequest(HttpRequest request) async {
    request.response.headers.contentType = ContentType.json;
    try {
      await _handleRequest(request);
    }
    catch (e) {
      print('Exception in handleRequest: $e');
      _writeError(request, HttpStatus.internalServerError, e);
    }
    finally {
      await request.response.close();
      print('Request handled');
    }
  }

  Future<void> _handleRequest(HttpRequest request) async {
    if (request.uri.path == GetHelpEndpoint) {
      switch (request.method) {
        case 'POST':
          print('Need help');
          break;

        default:
          print('Invalid method');
          _writeError(request, HttpStatus.methodNotAllowed);
          break;
      }
    }
    else if (request.uri.path == OfferHelpEndpoint) {
      switch (request.method) {
        case 'GET':
          print('Offered help');
          break;

        default:
          print('Invalid method');
          _writeError(request, HttpStatus.methodNotAllowed);
          break;
      }
    }
    else {
      print('Invalid path');
      _writeError(request, HttpStatus.forbidden);
    }
  }

  void _writeError(HttpRequest request, int statusCode, [String error]) {
    error = error ?? statusCode.toString();
    request.response
      ..statusCode = statusCode
      ..headers.contentType = ContentType.json
      ..write(jsonEncode({
        'error': error
      }));
  }

  Future<void> _onDone() async {

  }

  Future<void> _onError(error) async {
    print('Server error $error');
  }
}