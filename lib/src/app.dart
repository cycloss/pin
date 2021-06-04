import 'dart:io';

import 'package:pin/src/route.dart';
import 'package:pin/src/route_manager.dart';

/// Creates a new web app which defaults to address 'localhost' on port 8080
class App {
  RouteManager rm = RouteManager();
  Context c = Context();

  String address;
  int port;

  App([this.address = 'localhost', this.port = 8080]);

  /// Starts the app's web server listening on the specified address and port
  Future<void> start() async {
    var socket = await ServerSocket.bind(address, port);
    var server = HttpServer.listenOn(socket);
    server.listen(_handleRequest);
  }

  void _handleRequest(HttpRequest request) async {
    try {
      var response = Response();
      var controller = rm.getController(request.uri.path);
      switch (request.method) {
        case 'GET':
          controller.get(response, c);
          break;
        default:
          stderr.writeln('Unknown method ${request.method}');
      }
      var httpResp = request.response;
      httpResp.statusCode = response.statusCode;
      httpResp.headers.contentType = response.contentType;
      httpResp.write(response.message);
      await request.response.close();
    } catch (e) {
      stderr.writeln(e);
      stderr.writeln('Could not find a controller for the requested url');
    }
  }

  void addRoute(String route, Type classType) => rm.addRoute(route, classType);
}
