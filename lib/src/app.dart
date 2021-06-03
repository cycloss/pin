import 'dart:io';

import 'package:bridge/src/route.dart';
import 'package:bridge/src/route_manager.dart';

// when a query comes in, pass it into the mirror system to instantiate its handler
class App {
  RouteManager rm = RouteManager();
  Context c = Context();

  void handleRequest(HttpRequest? request) {
    // TODO remove hard coded url
    var url = '/';
    var method = 'GET';
    try {
      var controller = rm.getController(url);
      switch (method) {
        case 'GET':
          controller.get(c);
          break;
        default:
          stderr.writeln('Unknown method $method');
      }
    } catch (e) {
      stderr.writeln(e);
      stderr.writeln('Could not find a controller for the requested url');
    }
  }
}
