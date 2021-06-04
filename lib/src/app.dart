import 'dart:async';
import 'dart:io';

import 'package:pin/src/route.dart';
import 'package:pin/src/route_manager.dart';

/// Creates a new web app which defaults to address 'localhost' on port 8080
class App {
  RouteManager rm = RouteManager();
  Context c = Context();
  HttpServer? _server;

  String address;
  int port;

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
      var response = Response();
      var bundle = rm.getRouteBundle(request.uri.path);
      var controller = bundle.controller;
      var paramMap = bundle.paramMap;
      switch (request.method) {
        case 'GET':
          controller.get(response, c, paramMap);
          break;
        default:
          stderr.writeln('Unknown method ${request.method}');
      }
      await _finaliseResponse(request, response);
    } catch (e) {
      stderr.writeln(e);
      stderr.writeln('Could not find a controller for the requested url');
    }
  }

  Future<void> _finaliseResponse(HttpRequest request, Response response) async {
    var httpResp = request.response;
    httpResp.statusCode = response.statusCode;
    httpResp.headers.contentType = response.contentType;
    httpResp.write(response.message);
    await request.response.close();
  }

  void addRoute(String route, Type classType) => rm.addRoute(route, classType);
}
