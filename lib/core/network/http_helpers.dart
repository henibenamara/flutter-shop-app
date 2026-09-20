import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../error/exceptions.dart';

/// Runs [call] with a timeout and maps transport problems to [NetworkException].
Future<http.Response> sendRequest(Future<http.Response> Function() call) async {
  try {
    return await call().timeout(ApiConfig.timeout);
  } on TimeoutException {
    throw const NetworkException('The request timed out. Check your connection.');
  } on http.ClientException {
    throw const NetworkException('Could not reach the server. Check your connection.');
  }
}

/// Throws a [ServerException] unless the response is 2xx.
void ensureSuccess(http.Response response) {
  if (response.statusCode >= 200 && response.statusCode < 300) return;
  throw ServerException(
    messageFrom(response, fallback: 'Request failed (${response.statusCode}).'),
    statusCode: response.statusCode,
  );
}

/// Decodes a JSON object body, or throws a [ServerException].
Map<String, dynamic> decodeObject(http.Response response) {
  final decoded = _tryDecode(response.body);
  if (decoded is Map<String, dynamic>) return decoded;
  throw ServerException(
    'Unexpected response from the server.',
    statusCode: response.statusCode,
  );
}

/// Reads the "message" field DummyJSON uses for errors, if there is one.
String messageFrom(http.Response response, {required String fallback}) {
  final decoded = _tryDecode(response.body);
  if (decoded is Map<String, dynamic>) {
    final message = decoded['message'];
    if (message is String && message.isNotEmpty) return message;
  }
  return fallback;
}

/// Runs [parse] and turns a malformed payload into a [ServerException].
T parseOrThrow<T>(T Function() parse) {
  try {
    return parse();
  } on TypeError {
    throw const ServerException('Unexpected response from the server.');
  }
}

Object? _tryDecode(String body) {
  try {
    return jsonDecode(body);
  } on FormatException {
    return null;
  }
}
