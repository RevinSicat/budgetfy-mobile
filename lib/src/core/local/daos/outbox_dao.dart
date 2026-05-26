import 'package:drift/drift.dart';
import '../local_database.dart';

part 'outbox_dao.g.dart';

@DriftAccessor(tables: [Outbox])
class OutboxDao extends DatabaseAccessor<LocalDatabase> with _$OutboxDaoMixin {
    OutboxDao(super.db);

    /// [GET]: Retrieve all unsynced outbox entries ordered by createdAt
    Future<List<OutboxData>> getAllUnsynced() {
        return (
            select(outbox)
                ..where((t) => t.synced.equals(false))
                ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
        ).get();
    }

    /// [POST]: Insert outbox entry
    Future<void> insertEntry(OutboxCompanion entry) {
        return into(outbox).insert(entry);
    }

    /// [PUT]: Mark list of outbox entries as synced by {ids}
    Future<void> markSyncedByIds(List<String> ids) {
        return (
            update(outbox)
                ..where((t) => t.id.isIn(ids))
        ).write(const OutboxCompanion(
            synced: Value(true),
        ));
    }

    /// [DELETE]: Delete all synced outbox entries (cleanup)
    Future<void> deleteSynced() {
        return (
            delete(outbox)
                ..where((t) => t.synced.equals(true))
        ).go();
    }
}