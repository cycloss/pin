# Pin

If Flask for Python is a micro web app framework, then Pin is a pico framework.

pin is written in pure Dart and allows you to create APIs using a simple syntax that uses annotations.

## Usage

A simple usage example:

```dart
import 'package:pin/pin.dart';
import 'package:pin/src/route.dart';

@Route('/')
class MainRoute extends RouteController {
  @override
  void get(Context context) {
    print('In main route');
    print(context.message);
  }
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme

## How does it work?

pin uses Dart's `mirrors` API to find the classes you have written, then  instantiates and calls methods on them.
