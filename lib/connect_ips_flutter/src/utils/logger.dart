import 'dart:io';

class Logger {
  Logger(this.method, this.url);

  final String method;
  final String url;

  void request(Object? data) {
    _divider();
    _logHeading();
    _log(
      data.toString(),
      name: method == 'GET' ? 'Query Parameters' : 'Request Data',
    );
    _divider();
  }

  void response(HttpResponse response) {
    _divider();
    _logHeading();
    _log(response.toString(), name: 'Response');
    _divider();
  }

  void _logHeading() => _log(url, name: method);

  void _log(String message, {required String name}) {
    _debugPrint('[$name] $message');
  }

  void _divider() {
    _debugPrint('-' * 140);
  }

  void _debugPrint(String message) {
    assert(() {
      // ignore: avoid_print
      print(message);
      return true;
    }());
  }
}
