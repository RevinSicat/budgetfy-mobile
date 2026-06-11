import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'daos/account_dao.dart';
import 'daos/category_dao.dart';
import 'daos/subcategory_dao.dart';
import 'daos/transaction_dao.dart';
import 'daos/sync_meta_dao.dart';

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
    tables: [Accounts, Categories, Subcategories, Transactions, SyncMeta],
    daos: [AccountDao, CategoryDao, SubcategoryDao, TransactionDao, SyncMetaDao]
)
class LocalDatabase extends _$LocalDatabase {
    LocalDatabase() : super(_openConnection());

    @override
    int get schemaVersion => 1;

    static QueryExecutor _openConnection() {
        return driftDatabase(name: 'budgetfy_local');
    }

    // DAO accessors — used as db.accountDao.getAllAccounts() etc.
    AccountDao     get accountDao     => AccountDao(this);
    CategoryDao    get categoryDao    => CategoryDao(this);
    SubcategoryDao get subcategoryDao => SubcategoryDao(this);
    TransactionDao get transactionDao => TransactionDao(this);
    SyncMetaDao    get syncMetaDao    => SyncMetaDao(this);
}