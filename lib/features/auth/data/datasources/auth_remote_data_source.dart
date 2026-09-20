import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/http_helpers.dart';
import '../models/session_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<SessionModel> login({
    required String username,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);

  final http.Client _client;

  @override
  Future<SessionModel> login({
    required String username,
    required String password,
  }) async {
    final response = await sendRequest(
      () => _client.post(
        Uri.https(ApiConfig.host, '/auth/login'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'expiresInMins': 60,
        }),
      ),
    );

    if (response.statusCode == 400 || response.statusCode == 401) {
      throw AuthException(
        messageFrom(response, fallback: 'Invalid username or password.'),
      );
    }
    ensureSuccess(response);
    return parseOrThrow(() => SessionModel.fromJson(decodeObject(response)));
  }
}
