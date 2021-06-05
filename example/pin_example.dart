import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:pin/pin.dart';

@Route('/')
class BaseRoute extends RouteController {
  @override
  void get(HttpRequest request, Context context, Map<String, String> params) {}
}

@Route('/users/<name>/')
class HelloRoute extends RouteController {
  @override
  void get(HttpRequest request, Context ctxt, Map<String, String> params) {
    var message = 'Hello ${params['name']}';
    request.response.write(message);
  }
}

@Route('/random/<max>/')
class RandomRoute extends RouteController {
  @override
  void get(HttpRequest request, Context ctxt, Map<String, String> params) {
    var randomService = ctxt.getService<RandomNumService>();
    var response = request.response;
    var max = params['max'];
    if (max == null) {
      response.write('max must be an integer');
      return;
    }
    try {
      var maxInt = int.parse(max);
      var rand = randomService.generateRandomNumber(maxInt);
      response.write(rand);
    } catch (e) {
      response.write('max must be an integer');
    }
  }
}

class RandomNumService {
  Random r = Random();

  int generateRandomNumber(int max) => r.nextInt(max);
}

void main() async {
  // App setup
  var app = App();
  app.addService(RandomNumService());
  app.addRoute(BaseRoute);
  app.addRoute(HelloRoute);
  app.addRoute(RandomRoute);
  await app.start();

  // Client setup
  var client = HttpClient();
  var request = await client.get('localhost', 8080, '/');
  var response = await request.close();
  await printResponseBody(response);

  var request2 = await client.get('localhost', 8080, '/users/bar');
  var response2 = await request2.close();
  await printResponseBody(response2);

  var request3 = await client.get('localhost', 8080, '/random/10/');
  var response3 = await request3.close();
  await printResponseBody(response3);
}

Future<void> printResponseBody(HttpClientResponse resp) async =>
    print(await resp.transform(utf8.decoder).join());
