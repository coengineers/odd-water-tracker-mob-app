import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/db/app_database.dart';
import 'package:water_log/repositories/settings_repository.dart';

void main() {
  group('SettingsRepository', () {
    late AppDatabase db;
    late SettingsRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = SettingsRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('getTarget() returns 2000 default', () async {
      final target = await repo.getTarget();
      expect(target, equals(2000));
    });

    test('setTarget() updates and persists', () async {
      await repo.setTarget(3000);
      final target = await repo.getTarget();
      expect(target, equals(3000));
    });

    test('setTarget() throws for value below 250', () {
      expect(
        () => repo.setTarget(249),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('setTarget() throws for value above 10000', () {
      expect(
        () => repo.setTarget(10001),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('setTarget() accepts boundary value 250', () async {
      await repo.setTarget(250);
      final target = await repo.getTarget();
      expect(target, equals(250));
    });

    test('setTarget() accepts boundary value 10000', () async {
      await repo.setTarget(10000);
      final target = await repo.getTarget();
      expect(target, equals(10000));
    });
  });
}
