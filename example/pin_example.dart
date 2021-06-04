import 'dart:convert';
import 'dart:io';

import 'package:pin/pin.dart';

class BaseRoute extends RouteController {
  @override
  void get(Response resp, Context context) {
    resp.message = 'Hello world!';
  }
}

void main() async {
  // App setup
  var app = App();
  app.addRoute('/', BaseRoute);
  await app.start();

  // Client setup
  var client = HttpClient();
  var request = await client.get('localhost', 8080, '/');
  var response = await request.close();
  print(await response.transform(utf8.decoder).join());
}
