class RouteParser {
  int currenti = 0;
  int tokenStart = 0;
  bool paramTokenStarted = false;
  late String routeUrl;

  String getCharAt(int index) => routeUrl.substring(index, index + 1);

  /// Splits up path into segments
  /// ? indicates a parameter
  List<String> generatePathList(String url) {
    resetParser();
    routeUrl = url;
    testStart();
    var pathSegs = <String>[];
    while (currenti < routeUrl.length) {
      var currentChar = getCharAt(currenti);
      if (currentChar == '/' && tokenStart == 0) {
        tokenStart = currenti + 1;
      } else if (currentChar == '/') {
        var seg = routeUrl.substring(tokenStart, currenti);

        pathSegs.add(seg);
        tokenStart = currenti + 1;
      } else if (currentChar == '<') {
        startParamToken();
      } else if (currentChar == '>' && tokenStart != 0) {
        endParamToken();
        // skip over the forward slash
        currenti++;
        pathSegs.add('?');
      } else {
        checkCurrent();
      }
      currenti++;
    }
    validatePathSegs(pathSegs);
    validateParamFormat();
    return pathSegs;
  }

  List<String> generateParamList(String url) {
    resetParser();
    routeUrl = url;
    testStart();
    var paramList = <String>[];
    while (currenti < routeUrl.length) {
      var currentChar = getCharAt(currenti);
      if (currentChar == '<') {
        startParamToken();
      } else if (currentChar == '>' && tokenStart != 0) {
        paramList.add(endParamToken());
      } else {
        checkCurrent();
      }
      currenti++;
    }
    validateParamFormat();
    return paramList;
  }

  void startParamToken() {
    if (paramTokenStarted) {
      throw FormatException(
          'another opening bracket < cannot come before a closing bracket >');
    }
    if (currenti == 0 || getCharAt(currenti - 1) != '/') {
      throw FormatException(
          'forward slash / must come before parameter opening angle bracket <');
    }
    tokenStart = currenti + 1;
    paramTokenStarted = true;
  }

  String endParamToken() {
    var param = routeUrl.substring(tokenStart, currenti);
    if (!paramTokenStarted) {
      throw FormatException('No opening bracket < to match closing bracket >');
    }
    if (param.isEmpty) {
      throw FormatException('Empty route parameter <> is not allowed');
    }
    // only permits angle bracket without / next if end token
    if (currenti != routeUrl.length - 1) {
      var nextChar = getCharAt(currenti + 1);
      if (nextChar != '/') {
        throw FormatException(
            'forward slash / must come after parameter closing angle bracket >');
      }
    }
    // next token will be past the forward slash
    tokenStart = currenti + 2;
    paramTokenStarted = false;
    return param;
  }

  void validateParamFormat() {
    if (paramTokenStarted) {
      throw FormatException('Unterminated parameter is not allowed');
    }
  }

  void resetParser() {
    currenti = 0;
    tokenStart = 0;
    paramTokenStarted = false;
  }

  void checkCurrent() {
    if (paramTokenStarted && getCharAt(currenti) == '/') {
      throw FormatException(
          'forward slash / is not allowed in a parameter name');
    }
  }

  void validatePathSegs(List<String> pathSegs) {
    // adds a token if one has been started
    if (tokenStart != currenti) {
      pathSegs.add(routeUrl.substring(tokenStart, currenti));
    }
    // checks for invalid empty routes
    if (pathSegs.isEmpty) {
      if (routeUrl == '/') {
        // do nothing
      } else if (tokenStart != 0) {
        pathSegs.add(routeUrl.substring(tokenStart, currenti));
      } else {
        throw FormatException('An empty route is not allowed');
      }
    } else if (pathSegs.length > 1) {
      for (var seg in pathSegs) {
        if (seg.isEmpty) {
          throw FormatException(
              "Only the route '/' is allowed to have an empty path segment");
        }
      }
    }
  }

  void testStart() {
    if (routeUrl.isEmpty) {
      throw FormatException('Empty routes are not allowed');
    } else if (routeUrl[0] != '/') {
      throw FormatException('Routes must begin with forward slash');
    }
  }
}

void main() {}
