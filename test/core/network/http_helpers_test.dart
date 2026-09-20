import 'dart:convert';

import 'package:flutter_shop_app/core/error/exceptions.dart';
import 'package:flutter_shop_app/core/network/http_helpers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('sendRequest', () {
    test('returns the response', () async {
      final response = await sendRequest(() async => http.Response('ok', 200));

      expect(response.body, 'ok');
    });

    test('maps a client error to NetworkException', () async {
      await expectLater(
        sendRequest(() async => throw http.ClientException('offline')),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('ensureSuccess', () {
    test('accepts any 2xx status', () {
      expect(() => ensureSuccess(http.Response('{}', 204)), returnsNormally);
    });

    test('throws with the server message and status code', () {
      final response = http.Response(jsonEncode({'message': 'Not found'}), 404);

      expect(
        () => ensureSuccess(response),
        throwsA(
          isA<ServerException>()
              .having((e) => e.message, 'message', 'Not found')
              .having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    });

    test('falls back to a generic message', () {
      expect(
        () => ensureSuccess(http.Response('oops', 500)),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Request failed (500).',
          ),
        ),
      );
    });
  });

  group('decodeObject', () {
    test('decodes a JSON object', () {
      final json = decodeObject(http.Response('{"a": 1}', 200));

      expect(json, {'a': 1});
    });

    test('rejects a JSON array', () {
      expect(
        () => decodeObject(http.Response('[1, 2]', 200)),
        throwsA(isA<ServerException>()),
      );
    });

    test('rejects text that is not JSON', () {
      expect(
        () => decodeObject(http.Response('<html>', 200)),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('parseOrThrow', () {
    test('returns the parsed value', () {
      expect(parseOrThrow(() => 7), 7);
    });

    test('turns a bad cast into a ServerException', () {
      const Object? value = 5;

      expect(
        () => parseOrThrow(() => value as String),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
