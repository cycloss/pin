import 'dart:io';

class Context {
  // gets parent's context gets copied into child so child has access to all controllers given to its ancestors
  // will not have access to controllers in different branches of the tree
  Map<Type, Object> inheretedResources = {};

  T getService<T>() {
    var service = inheretedResources[T] as T;
    return service;
  }

  void addService<T extends Object>(T service) =>
      inheretedResources[T] = service;
}

class Route {
  final String url;
  const Route(this.url);
}

abstract class RouteController {
  // default implementations do nothing
  void get(HttpRequest request, Context ctxt, Map<String, String> params) {}

  void post(HttpRequest request, Context ctxt, Map<String, String> params) {}

  void patch(HttpRequest request, Context ctxt, Map<String, String> params) {}

  void delete(HttpRequest request, Context ctxt, Map<String, String> params) {}
}
