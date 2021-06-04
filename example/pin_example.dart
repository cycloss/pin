import 'dart:convert';
import 'dart:io';

import 'package:pin/pin.dart';

class BaseRoute extends RouteController {
  @override
  void get(Response resp, Context context, Map<String, String> params) {
    resp.message = 'Hello world!';
  }
}

class ComplexRoute extends RouteController {
  @override
  void get(Response resp, Context ctxt, Map<String, String> params) {
    var message = 'Hello ${params['name']}';
    resp.message = message;
  }
}

void main() async {
  // App setup
  var app = App();
  app.addRoute('/', BaseRoute);
  app.addRoute('/users/<name>/', ComplexRoute);
  await app.start();

  // Client setup
  var client = HttpClient();
  var request = await client.get('localhost', 8080, '/');
  var response = await request.close();
  await printResponseBody(response);

  var request2 = await client.get('localhost', 8080, '/users/bar/');
  var response2 = await request2.close();
  await printResponseBody(response2);
}

Future<void> printResponseBody(HttpClientResponse resp) async =>
    print(await resp.transform(utf8.decoder).join());
