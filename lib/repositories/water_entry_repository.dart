import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';

class WaterEntryRepository {
  WaterEntryRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Future<WaterEntry> add({required int amountMl, DateTime? entryTs}) {
    if (amountMl < 1 || amountMl > 5000) {
      throw ArgumentError.value(
        amountMl,
        'amountMl',
        'Must be between 1 and 5000',
      );
    }

    final ts = entryTs ?? DateTime.now();
    final tsIso = ts.toIso8601String();
    final dateStr = tsIso.substring(0, 10);
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    return _db
        .into(_db.waterEntries)
        .insertReturning(
          WaterEntriesCompanion.insert(
            id: id,
            entryTs: tsIso,
            entryDate: dateStr,
            amountMl: amountMl,
            createdAt: now,
          ),
        );
  }

  Future<List<WaterEntry>> listByDate(String entryDate) {
    final query = _db.select(_db.waterEntries)
      ..where((t) => t.entryDate.equals(entryDate))
      ..orderBy([(t) => OrderingTerm.desc(t.entryTs)]);
    return query.get();
  }

  Future<bool> delete(String id) async {
    final count = await (_db.delete(_db.waterEntries)
          ..where((t) => t.id.equals(id)))
        .go();
    return count > 0;
  }
}
