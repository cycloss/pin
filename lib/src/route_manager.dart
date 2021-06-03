import 'dart:mirrors';

import 'package:pin/src/route.dart';
import 'package:pin/src/route_tree.dart';

/// Handles the creation of route map at runtime
class RouteManager {
  RouteTree rt = RouteTree();

  RouteManager() {
    generateRoutes();
  }

  RouteController getController(String requestUrl) {
    var cm = rt.getMirrorForUrl(requestUrl);
    var im = cm.newInstance(Symbol(''), []);
    return im.reflectee as RouteController;
  }

  // adds all routes to the tree
  void generateRoutes() {
    var lm = currentMirrorSystem().isolate.rootLibrary;
    for (var dm in lm.declarations.values) {
      if (dm is! ClassMirror) continue;
      var route = getRouteName(dm.metadata);
      if (route == null) continue;
      if (!isRouteController(dm)) continue;
      if (!hasDefaultConstructor(dm)) continue;
      try {
        rt.addRoute(route, dm);
      } catch (e) {
        print('Failed to add route: $route');
        print(e);
      }
    }
  }

  static String? getRouteName(List<InstanceMirror> metaDatas) {
    for (var metaData in metaDatas) {
      if (metaData.reflectee is Route) {
        return metaData.reflectee.url;
      }
    }
    return null;
  }

  static bool isRouteController(ClassMirror cm) {
    // works even when something is a subclass of a subclass like Second route
    return cm.isSubclassOf(reflectClass(RouteController));
  }

  static bool hasDefaultConstructor(ClassMirror cm) {
    for (var dm in cm.declarations.values) {
      if (dm is MethodMirror &&
          dm.isConstructor &&
          dm.constructorName == Symbol('')) {
        return true;
      }
    }
    return false;
  }
}
