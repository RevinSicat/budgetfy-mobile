import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'daos/account_dao.dart';
import 'daos/category_dao.dart';
import 'daos/subcategory_dao.dart';
import 'daos/transaction_dao.dart';
import 'daos/sync_meta_dao.dart';
import 'daos/outbox_dao.dart';

part 'local_database.g.dart';

/// ===============================================================================================
/// Entity Tables
/// ===============================================================================================

@DataClassName('AccountData')
class Accounts extends Table {
    TextColumn get id          => text()();
    TextColumn get name        => text()();
    TextColumn get color       => text()();
    DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
    BoolColumn get isDeleted   => boolean().withDefault(const Constant(false))();
    BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();

    @override
    Set<Column> get primaryKey => {id};
}

@DataClassName('CategoryData')
class Categories extends Table {
    TextColumn get id          => text()();
    TextColumn get name        => text()();
    TextColumn get color       => text()();
    TextColumn get type        => text()(); // 'income' | 'expense'
    DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
    BoolColumn get isDeleted   => boolean().withDefault(const Constant(false))();
    BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();

    @override
    Set<Column> get primaryKey => {id};
}

@DataClassName('SubcategoryData')
class Subcategories extends Table {
    TextColumn get id          => text()();
    TextColumn get categoryId  => text()();
    TextColumn get name        => text()();
    DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
    BoolColumn get isDeleted   => boolean().withDefault(const Constant(false))();
    BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();

    @override
    Set<Column> get primaryKey => {id};
}

@DataClassName('TransactionData')
class Transactions extends Table {
    TextColumn get id              => text()();
    TextColumn get accountId       => text()();
    TextColumn get categoryId      => text()();
    TextColumn get subcategoryId   => text().nullable()();
    RealColumn get amount          => real()();
    DateTimeColumn get date        => dateTime()();
    TextColumn get transactionType => text()();
    TextColumn get note            => text().withDefault(const Constant(''))();
    DateTimeColumn get updatedAt   => dateTime().withDefault(currentDateAndTime)();
    BoolColumn get isDeleted       => boolean().withDefault(const Constant(false))();
    BoolColumn get pendingSync     => boolean().withDefault(const Constant(true))();

    @override
    Set<Column> get primaryKey => {id};
}

@DataClassName('OutboxData')
class Outbox extends Table {
    TextColumn get id         => text()();
    TextColumn get tblName  => text()();
    TextColumn get recordId   => text()();
    TextColumn get operation  => text()();
    TextColumn get payload    => text()();
    DateTimeColumn get createdAt => dateTime()();
    BoolColumn get synced     => boolean().withDefault(const Constant(false))();

    @override
    Set<Column> get primaryKey => {id};
}

/// ===============================================================================================
/// Sync Meta Table
/// ===============================================================================================

class SyncMeta extends Table {
    TextColumn get tableKey        => text()();
    DateTimeColumn get lastSyncedAt => dateTime()();

    @override
    Set<Column> get primaryKey => {tableKey};
}

/// ===============================================================================================
/// Database
/// ===============================================================================================

@DriftDatabase(
    tables: [Accounts, Categories, Subcategories, Transactions, SyncMeta, Outbox],
    daos: [AccountDao, CategoryDao, SubcategoryDao, TransactionDao, SyncMetaDao, OutboxDao]
)
class LocalDatabase extends _$LocalDatabase {
    LocalDatabase() : super(_openConnection());

    @override
    int get schemaVersion => 2; // bump this from 1 to 2

    @override
    MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
            if (from < 2) {
                await migrator.createTable(outbox); // create the new table
            }
        },
    );

    static QueryExecutor _openConnection() {
        return driftDatabase(name: 'budgetfy_local');
    }

    AccountDao     get accountDao     => AccountDao(this);
    CategoryDao    get categoryDao    => CategoryDao(this);
    SubcategoryDao get subcategoryDao => SubcategoryDao(this);
    TransactionDao get transactionDao => TransactionDao(this);
    SyncMetaDao    get syncMetaDao    => SyncMetaDao(this);
    OutboxDao      get outboxDao      => OutboxDao(this);
}