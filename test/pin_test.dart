import 'dart:io';

import 'package:pin/src/route.dart';
import 'package:pin/src/route_manager.dart';
import 'package:pin/src/route_parser.dart';
import 'package:pin/src/segmented_url.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

@Route('/')
class MainRoute extends RouteController {
  @override
  void get(HttpRequest request, Context ctxt, Map<String, String> paramMap) {
    print('In main route');
  }
}

@Route('/second')
class SecondRoute extends MainRoute {
  @override
  void get(HttpRequest request, Context ctxt, Map<String, String> paramMap) {
    print('In second route');
  }
}

@Route('/users/<id>/')
class ThirdRoute extends MainRoute {}

void main() {
  group('Parser tests', () {
    var rp = RouteParser();
    test('param list test', () {
      var expected = ['id', 'b', 'dc', 'aa'];
      var actual = rp.generateParamList('/hello/<id>/<b>/car/<dc>/<aa>/');
      expect(actual, expected);

      var exp2 = [];
      var act2 = rp.generateParamList('/hello');
      expect(act2, exp2);

      var exp3 = ['cat'];
      var act3 = rp.generateParamList('/<cat>');
      expect(act3, exp3);

      var exp4 = ['id'];
      var act4 = rp.generateParamList('/person/<id>');
      expect(act4, exp4);

      expect(() => rp.generatePathList('hello/<world>'), throwsFormatException);
    });

    test('path list test', () {
      var exp1 = ['?', 'cat', 'bat', '?'];
      var act1 = rp.generatePathList('/<mat>/cat/bat/<m>/');
      expect(act1, exp1);

      var exp2 = ['hello'];
      var act2 = rp.generatePathList('/hello');
      expect(act2, exp2);

      var exp3 = ['?'];
      var act3 = rp.generatePathList('/<cat>');
      expect(act3, exp3);

      var exp4 = [];
      var act4 = rp.generatePathList('/');
      expect(act4, exp4);

      expect(() => rp.generatePathList('hello'), throwsFormatException);

      var exp5 = ['hello'];
      var act5 = rp.generatePathList('/hello/');
      expect(act5, exp5);
    });
  });

  group('SegmentedUrl test', () {
    test('1', () {
      var s = SegmentedUrl('/');
      expect(List.from(s), []);

      var s2 = SegmentedUrl('/hello');
      expect(List.from(s2), ['hello']);

      var s3 = SegmentedUrl('/hello/');
      expect(List.from(s3), ['hello']);
    });
  });

  test('Route insert tests', () {
    var rm = RouteManager();
    rm.addRoute(MainRoute);
    var c1 = rm.getRouteBundle('/').controller;
    expect(MainRoute, c1.runtimeType);

    rm.addRoute(SecondRoute);
    var c2 = rm.getRouteBundle('/second').controller;
    expect(SecondRoute, c2.runtimeType);

    rm.addRoute(ThirdRoute);
    var c3 = rm.getRouteBundle('/users/235').controller;
    expect(ThirdRoute, c3.runtimeType);
  });
}
