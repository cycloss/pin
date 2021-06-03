/// breaks the url up into segments used to traverse route tree
class SegmentedUrl extends Iterable with Iterator<String> {
  final String url;
  // start after the opening /
  int i = 0;
  int i2 = -1;

  SegmentedUrl(this.url) {
    if (url.isEmpty) {
      throw FormatException('Empty urls are not allowed');
    }
    if (url[0] != '/') {
      throw FormatException('Urls must start with forward slash /');
    }
  }

  // must return a new iterator every time
  @override
  Iterator get iterator => SegmentedUrl(url);

  @override
  String get current => url.substring(i, i2);

  @override
  bool moveNext() {
    i = ++i2;
    // skips over the first /
    if (i2 == 0) {
      i = ++i2;
    }
    while (true) {
      if (i2 >= url.length) {
        // checks if the last segment was not /, in which case there is a path segment not iterated
        if (i2 - 1 < url.length && url[i2 - 1] != '/') {
          return true;
        }
        return false;
      } else if (url[i2] == '/') {
        return true;
      } else {
        i2++;
      }
    }
  }
}
