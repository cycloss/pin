import 'dart:mirrors';

import 'package:pin/src/route.dart';
import 'package:pin/src/route_tree.dart';

import 'route_bundle.dart';

/// Handles the creation of route map at runtime
class RouteManager {
  RouteTree rt = RouteTree();

  void addRoute(Type classType) {
    var cm = reflectClass(classType);
    var route = getRoute(cm);
    checkRouteController(cm);
    checkNoArgsConstructor(cm);
    if (route == null) {
      throw Exception('No route annotation found for class $classType');
    }
    rt.addRoute(route, cm);
  }

  RouteBundle getRouteBundle(String requestUrl) {
    return rt.getBundleForUrl(requestUrl);
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

  String? getRoute(ClassMirror cm) {
    for (var d in cm.metadata) {
      if (d.reflectee is Route) {
        return d.reflectee.url;
      }
    }
    return null;
  }
}
