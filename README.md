# Pin

If Flask for Python is a micro web app framework, then Pin is a pico framework.

Pin is written in pure Dart and allows you to create APIs using a simple syntax that uses annotations.

## Usage

The most simple example of an app using Pin looks like this:

```dart
import 'package:pin/pin.dart';
import 'dart:io';

@Route('/')
class BaseRoute extends RouteController {
  @override
  void get(HttpRequest req, Context context) {
    req.response.write('Hello world!');
  }
}

void main() async {
  var app = App();
  app.addRoute(BaseRoute);
  await app.start();
}
```

This can then be queried by a client by subsequently running this:

```dart
import 'dart:convert';
import 'dart:io';

void main() async {
  var client = HttpClient();
  var request = await client.get('localhost', 8080, '/');
  var response = await request.close();
  print(await response.transform(utf8.decoder).join());
}
```

## A More Complex Example

See `example/pin_example.dart` to see how to use path parameters, and services added to the app.

## How does it work?

Pin uses Dart's `mirrors` API examine the classes you passed into `app.addRoute` and checks for three conditions:

1. A valid `Route` annotation
2. That the class inherits from `RouteController`
3. That the class has a no args constructor

When a route is called by a client, the app will then instantiate a corresponding class to respond to that client's query.
