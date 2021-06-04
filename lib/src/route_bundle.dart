import 'dart:mirrors';

import 'package:pin/src/route.dart';

import 'route_tree.dart';

class RouteBundle {
  final RouteController controller;
  final Map<String, String> paramMap;

  RouteBundle(Node node, List<String> requestParams)
      : controller = _generateController(node.cm!),
        paramMap = _generateParamMap(requestParams, node.pathParams!);

  static RouteController _generateController(ClassMirror cm) {
    var im = cm.newInstance(Symbol(''), []);
    return im.reflectee as RouteController;
  }

  static Map<String, String> _generateParamMap(
      List<String> requestParams, List<String> routeParams) {
    var map = <String, String>{};
    if (requestParams.length != routeParams.length) {
      throw Exception(
          'Path param list length differs from param list from request');
    }
    for (var i = 0; i < routeParams.length; i++) {
      map[routeParams[i]] = requestParams[i];
    }
    return map;
  }
}
