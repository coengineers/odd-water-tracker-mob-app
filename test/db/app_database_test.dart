import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/db/app_database.dart';

void main() {
  group('AppDatabase', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('initialises in-memory without errors', () {
      expect(db, isNotNull);
    });

    test('schemaVersion is 1', () {
      expect(db.schemaVersion, equals(1));
    });
  });
}
