class Context {
  // gets parent's context gets copied into child so child has access to all controllers given to its ancestors
  // will not have access to controllers in different branches of the tree
  Map<Type, Object> inheretedControllers = {};
  String message = 'hello world';

  T getController<T>() {
    var controller = inheretedControllers[T] as T;
    return controller;
  }

  void addController<T extends Object>(T controller) {
    inheretedControllers[T] = controller;
  }
}

class Route {
  final String url;
  const Route(this.url);
}

abstract class RouteController {
  // default implementations do nothing
  void get(Context context) {}

  // TODO add post delete ect
}
