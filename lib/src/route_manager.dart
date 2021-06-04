import 'dart:mirrors';

import 'package:pin/src/route.dart';
import 'package:pin/src/route_tree.dart';

/// Handles the creation of route map at runtime
class RouteManager {
  RouteTree rt = RouteTree();

  void addRoute(String route, Type classType) {
    var cm = reflectClass(classType);
    checkRouteController(cm);
    checkNoArgsConstructor(cm);
    rt.addRoute(route, cm);
  }

  RouteController getController(String requestUrl) {
    var cm = rt.getMirrorForUrl(requestUrl);
    var im = cm.newInstance(Symbol(''), []);
    return im.reflectee as RouteController;
  }

  void checkRouteController(ClassMirror cm) {
    // works even when something is a subclass of a subclass like Second route
    var isRouteController = cm.isSubclassOf(reflectClass(RouteController));
    if (!isRouteController) {
      throw Exception(
          'Class ${cm.reflectedType} must be a subclass of RouteController');
    }
  }

  void checkNoArgsConstructor(ClassMirror cm) {
    var hasNoArgs = false;
    for (var dm in cm.declarations.values) {
      if (dm is MethodMirror &&
          dm.isConstructor &&
          dm.constructorName == Symbol('')) {
        hasNoArgs = true;
      }
    }
    if (!hasNoArgs) {
      throw Exception(
          'Class ${cm.reflectedType} must have a no args constructor');
    }
  }
}
