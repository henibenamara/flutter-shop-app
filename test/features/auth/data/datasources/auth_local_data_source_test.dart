import 'package:flutter_shop_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures.dart';

Future<AuthLocalDataSourceImpl> _dataSource([
  Map<String, Object> stored = const {},
]) async {
  SharedPreferences.setMockInitialValues(stored);
  return AuthLocalDataSourceImpl(await SharedPreferences.getInstance());
}

void main() {
  test('returns null when nothing is stored', () async {
    final dataSource = await _dataSource();

    expect(await dataSource.readSession(), isNull);
  });

  test('reads back a saved session', () async {
    final dataSource = await _dataSource();

    await dataSource.saveSession(testSessionModel);

    expect(await dataSource.readSession(), testSessionModel);
  });

  test('forgets the session once cleared', () async {
    final dataSource = await _dataSource();
    await dataSource.saveSession(testSessionModel);

    await dataSource.clearSession();

    expect(await dataSource.readSession(), isNull);
  });

  test('discards a corrupted value instead of crashing', () async {
    final dataSource = await _dataSource({'auth.session': '{not json'});

    expect(await dataSource.readSession(), isNull);
  });

  test('discards a stored value with the wrong shape', () async {
    final dataSource = await _dataSource({'auth.session': '{"id": "x"}'});

    expect(await dataSource.readSession(), isNull);
  });
}
