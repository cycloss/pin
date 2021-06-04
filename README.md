# Pin

If Flask for Python is a micro web app framework, then Pin is a pico framework.

Pin is written in pure Dart and allows you to create APIs using a simple syntax that uses annotations.

## Usage

The most simple example of an app using Pin looks like this:

```dart
import 'package:pin/pin.dart';

class BaseRoute extends RouteController {
  @override
  void get(Response resp, Context context) {
    resp.message = 'Hello world!';
  }
}

void main() async {
  var app = App();
  app.addRoute('/', BaseRoute);
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

## How does it work?

Pin uses Dart's `mirrors` API to find the classes you have written, then  instantiates and calls methods on them.
