import 'dart:convert';
import 'dart:io';

import 'package:hack_heroes_server/HelpRequest.dart';
import 'package:hack_heroes_server/RequestQueue.dart';
import 'package:hack_heroes_server/firebase_client.dart';

class AppServer {
  AppServer();

  static const GetHelpEndpoint = '/getHelp';
  static const OfferHelpEndpoint = '/offerHelp';
  static const HelpNeededEndpoint = '/helpNeeded';
  static const CancelRequestEndpoint = '/cancelRequest';

  Future<void> start(int port) async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    server.listen(
      _onRequest,
      onDone: _onHttpDone,
      onError: _onHttpError,
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
      _writeError(request, HttpStatus.internalServerError, e.toString());
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
          print('POST $GetHelpEndpoint');

          final data = jsonDecode(await utf8.decoder.bind(request).join());
          final id = data['id'].toString();
          final text = data['text'].toString();
          final image = data['image'].toString();

          final helpRequest = HelpRequest(text, image, id);
          final place = _requestQueue.enqueue(helpRequest);

          await _fcm.broadcast('/topics/helpNeeded', 'Someone needs help', text);

          _writeJson(request, {
            'status': 'ok',
            'placeInQueue': place,
          });
          break;

        default:
          print('Invalid method');
          _writeError(request, HttpStatus.methodNotAllowed);
          break;
      }
    }
    else if (request.uri.path == CancelRequestEndpoint) {
      switch (request.method) {
        case 'POST':
          print('POST $CancelRequestEndpoint');

          final data = jsonDecode(await utf8.decoder.bind(request).join());
          final id = data['id'].toString();

          _requestQueue.removeID(id);

          _writeJson(request, {
            'status': 'ok',
          });
          break;

        default:
          print('Invalid method');
          _writeError(request, HttpStatus.methodNotAllowed);
          break;
      }
    }
    else if (request.uri.path == HelpNeededEndpoint) {
      switch (request.method) {
        case 'GET':
          print('GET $HelpNeededEndpoint');

          final first = _requestQueue.first;

          _writeJson(request, {
            'status': 'ok',
            'needed': first != null,
            'id': first?.id,
            'text': first?.text,
            'image': first?.image,
          });

          break;

        default:
          print('Invalid method');
          _writeError(request, HttpStatus.methodNotAllowed);
          break;
      }
    }
    else if (request.uri.path == OfferHelpEndpoint) {
      switch (request.method) {
        case 'POST':
          print('POST $OfferHelpEndpoint');

          final data = jsonDecode(await utf8.decoder.bind(request).join());
          final text = data['text'].toString();
          final id = data['id'].toString();

          final helpRequest = _requestQueue.getRequest(id);
          if (helpRequest == null) {
            _writeError(request, HttpStatus.notFound, 'Client not found');
          }
          else {
            print('Sending $text to $id');
            await _fcm.broadcast(id, 'Help received', text);
            _writeJson(request, {
              'status': 'ok'
            });

            _requestQueue.removeID(helpRequest.id);
          }
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

  void _writeJson(HttpRequest request, Map<String, dynamic> data, [int statusCode = HttpStatus.ok]) {
    request.response
      ..statusCode = statusCode
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(data));
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

  Future<void> _onHttpDone() async {

  }

  Future<void> _onHttpError(error) async {
    print('Server error $error');
  }

  final _requestQueue = RequestQueue();
  final _fcm = FirebaseClient();
}