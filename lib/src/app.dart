import 'dart:async';
import 'dart:io';

import 'package:pin/src/route.dart';
import 'package:pin/src/route_manager.dart';

/// Creates a new web app which defaults to address 'localhost' on port 8080
class App {
  RouteManager rm = RouteManager();
  Context context = Context();
  HttpServer? _server;

  String address;
  int port;

  String message404 = 'Route not found';
  ContentType contentType = ContentType.text;

  App([this.address = 'localhost', this.port = 8080]);

  /// Starts the app's web server listening on the specified address and port
  Future<void> start() async {
    var socket = await ServerSocket.bind(address, port);
    _server = HttpServer.listenOn(socket);
    _server?.listen(_handleRequest);
  }

  Future<void> stop() async => await _server?.close();

  void _handleRequest(HttpRequest request) async {
    try {
      var bundle = rm.getRouteBundle(request.uri.path);
      var controller = bundle.controller;
      var paramMap = bundle.paramMap;
      switch (request.method) {
        case 'GET':
          controller.get(request, context, paramMap);
          break;
        case 'POST':
          controller.post(request, context, paramMap);
          break;
        case 'PATCH':
          controller.patch(request, context, paramMap);
          break;
        case 'DELETE':
          controller.delete(request, context, paramMap);
          break;
        default:
          throw Exception('Unknown method ${request.method}');
      }
    } catch (e) {
      stderr.writeln(e);
      stderr.writeln('Could not find a controller for the requested url');
      // content type must be before writing a message
      request.response.headers.contentType = contentType;
      request.response.write(message404);
    }
    await _finaliseResponse(request);
  }

  Future<void> _finaliseResponse(HttpRequest request) async {
    await request.response.flush();
    await request.response.close();
  }

  void addRoute(Type classType) => rm.addRoute(classType);

  void addService<T extends Object>(T service) =>
      context.addService<T>(service);

  void set404Response(String message, ContentType type) {}
}
