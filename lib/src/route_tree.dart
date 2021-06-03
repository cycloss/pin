import 'dart:mirrors';

import 'package:pin/src/route_parser.dart';
import 'package:pin/src/segmented_url.dart';

/// A tree with maps at each level which store successive
/// components of paths. A class mirror checked by the route manager at the end
class RouteTree {
  // Root node contains class mirror for @Route('/')
  Node root = Node('');

  /// adds a route like /users/<id>/car/<color>/ into the tree, segment by segment
  void addRoute(String route, ClassMirror cm) {
    var rp = RouteParser();
    // can throw if invalid route syntax
    var pathList = rp.generatePathList(route);
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
  }

  /// walks down the tree based on url
  ClassMirror getMirrorForUrl(String url) {
    var current = root;

    for (var seg in SegmentedUrl(url)) {
      var next = current[seg];
      if (next == null) {
        // tries the wild card
        next = current['?'];
        if (next == null) {
          throw Exception('No class mirror found for url: $url');
        }
      }
      current = next;
    }
    var cm = current.cm;
    if (cm == null) {
      throw Exception('No class mirror found for url: $url');
    }
    return cm;
  }
}

class Node {
  String pathComponent;
  ClassMirror? cm;
  // TODO somehow keep the param list for the route in here
  Map<String, Node> children = {};
  Node(this.pathComponent);

  Node? operator [](String str) {
    return children[str];
  }

  void operator []=(String key, Node node) {
    children[key] = node;
  }
}
