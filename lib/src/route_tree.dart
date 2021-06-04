import 'dart:mirrors';

import 'package:pin/src/route_parser.dart';
import 'package:pin/src/segmented_url.dart';

import 'route_bundle.dart';

/// A tree with maps at each level which store successive
/// components of paths. A class mirror checked by the route manager is stored at the end
class RouteTree {
  // Root node contains class mirror for @Route('/')
  Node root = Node('');

  /// adds a route like /users/<id>/car/<color>/ into the tree, segment by segment
  void addRoute(String route, ClassMirror cm) {
    var rp = RouteParser();
    // can throw if invalid route syntax
    var pathList = rp.generatePathList(route);
    var params = rp.generateParamList(route);
    var curNode = root;
    for (var i = 0; i < pathList.length; i++) {
      var seg = pathList[i];
      if (curNode[seg] != null) {
        // ^if node already exists

        curNode = curNode[seg]!;
      } else {
        // ^if node doesn't exist for key
        var newNode = Node(seg);
        curNode[seg] = newNode;
        curNode = newNode;
      }
    }
    // checks for duplicate route at end
    if (curNode.cm != null) {
      throw Exception('Duplicate route pattern detected for $route');
    }
    curNode.cm = cm;
    curNode.pathParams = params;
  }

  /// walks down the tree based on url
  RouteBundle getBundleForUrl(String requestUrl) {
    var currentNode = root;

    var requestParams = <String>[];
    for (var seg in SegmentedUrl(requestUrl)) {
      var next = currentNode[seg];
      if (next == null) {
        // tries the wild card
        next = currentNode['?'];
        if (next == null) {
          throw Exception(
              'No class mirror found for requested url: $requestUrl');
        } else {
          // put the current segment in as a wildcard parameter
          requestParams.add(seg);
        }
      }
      currentNode = next;
    }
    try {
      return RouteBundle(currentNode, requestParams);
    } catch (e) {
      throw Exception(
          'No class mirror found for requested url: $requestUrl\n Exception: $e');
    }
  }
}

class Node {
  String pathComponent;
  ClassMirror? cm;
  List<String>? pathParams;
  Map<String, Node> children = {};
  Node(this.pathComponent);

  Node? operator [](String str) {
    return children[str];
  }

  void operator []=(String key, Node node) {
    children[key] = node;
  }
}
