import 'dart:convert';

import 'package:flutter_shop_app/core/error/exceptions.dart';
import 'package:flutter_shop_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../../../fixtures.dart';

http.Response _json(Object body, [int status = 200]) {
  return http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );
}

void main() {
  test('posts the credentials and returns the session', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return _json(loginResponse);
    });

    final session = await AuthRemoteDataSourceImpl(client)
        .login(username: 'emilys', password: 'emilyspass');

    expect(session.user.fullName, 'Emily Johnson');
    expect(session.accessToken, 'token-123');
    expect(captured.method, 'POST');
    expect(captured.url.path, '/auth/login');
    expect(jsonDecode(captured.body), containsPair('username', 'emilys'));
  });

  test('turns a 400 into an AuthException with the server message', () async {
    final client = MockClient(
      (_) async => _json({'message': 'Invalid credentials'}, 400),
    );

    await expectLater(
      AuthRemoteDataSourceImpl(client).login(username: 'x', password: 'y'),
      throwsA(
        isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Invalid credentials',
        ),
      ),
    );
  });

  test('turns a 500 into a ServerException', () async {
    final client = MockClient((_) async => _json({'message': 'Boom'}, 500));

    await expectLater(
      AuthRemoteDataSourceImpl(client).login(username: 'x', password: 'y'),
      throwsA(
        isA<ServerException>().having((e) => e.statusCode, 'statusCode', 500),
      ),
    );
  });

  test('turns a payload with missing fields into a ServerException', () async {
    final client = MockClient((_) async => _json({'id': 1}));

    await expectLater(
      AuthRemoteDataSourceImpl(client).login(username: 'x', password: 'y'),
      throwsA(isA<ServerException>()),
    );
  });

  test('turns a transport failure into a NetworkException', () async {
    final client = MockClient((_) async => throw http.ClientException('offline'));

    await expectLater(
      AuthRemoteDataSourceImpl(client).login(username: 'x', password: 'y'),
      throwsA(isA<NetworkException>()),
    );
  });
}
