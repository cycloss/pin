import 'package:bridge/bridge.dart';
import 'package:bridge/src/route.dart';
import 'package:bridge/src/route_manager.dart';
import 'package:bridge/src/route_parser.dart';
import 'package:bridge/src/segmented_url.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

@Route('/')
class MainRoute extends RouteController {
  @override
  void get(Context context) {
    print('In main route');
    print(context.message);
  }
}

@Route('/sec')
class SecondRoute extends MainRoute {
  @override
  void get(Context context) {
    print('In second route');
    print(context.message);
  }
}

@Route('/users/<id>/')
class ThirdRoute extends MainRoute {}

void main() {
  var app = App();
  app.handleRequest(null);

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
      expect(act2, exp2);
    });
  });

  group('SegmentedUrl test', () {
    test('1', () {
      var s = SegmentedUrl('/');
      expect(List.from(s), []);

      var s2 = SegmentedUrl('/hello');
      expect(List.from(s2), ['hello']);

      var s3 = SegmentedUrl('/hello/');
      expect(List.from(s2), ['hello']);
    });
  });

  test('Route insert tests', () {
    var rm = RouteManager();
    var c1 = rm.getController('/');
    expect(MainRoute, c1.runtimeType);

    var c2 = rm.getController('/sec');
    expect(SecondRoute, c2.runtimeType);

    var c3 = rm.getController('/users/235');
    expect(ThirdRoute, c3.runtimeType);
  });
}
