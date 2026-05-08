import 'package:drift/drift.dart';
import '../local_database.dart';

part 'sync_meta_dao.g.dart';

@DriftAccessor(tables: [SyncMeta])
class SyncMetaDao extends DatabaseAccessor<LocalDatabase> with _$SyncMetaDaoMixin {
    SyncMetaDao(super.db);

    /// [GET]: Retrieve Last Sync Timestamp by {tableKey}
    Future<DateTime?> getLastSyncedAtByTable(String tableKey) async {
        final row = await (
            select(syncMeta)
                ..where((t) => t.tableKey.equals(tableKey))
        ).getSingleOrNull();
        return row?.lastSyncedAt;
    }

    /// [PUT]: Upsert Last Sync Timestamp for {tableKey}
    Future<void> upsertLastSyncedAt(String tableKey, DateTime syncedAt) {
        return into(syncMeta).insertOnConflictUpdate(
            SyncMetaCompanion.insert(
                tableKey: tableKey,
                lastSyncedAt: syncedAt,
            ),
        );
    }
}