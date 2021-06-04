import 'dart:io';

class Context {
  // gets parent's context gets copied into child so child has access to all controllers given to its ancestors
  // will not have access to controllers in different branches of the tree
  Map<Type, Object> inheretedResources = {};

  T getController<T>() {
    var controller = inheretedResources[T] as T;
    return controller;
  }

  void addController<T extends Object>(T controller) {
    inheretedResources[T] = controller;
  }
}

class Response {
  String message = 'empty';
  int statusCode = 200;
  ContentType contentType = ContentType.json;
}

abstract class RouteController {
  // default implementations do nothing
  void get(Response resp, Context ctxt, Map<String, String> params) {}

  // TODO add post delete ect
}
