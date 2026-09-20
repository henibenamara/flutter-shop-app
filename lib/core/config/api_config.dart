/// Where the app talks to. DummyJSON is a free fake shop API.
abstract final class ApiConfig {
  static const String host = 'dummyjson.com';
  static const Duration timeout = Duration(seconds: 15);
}
