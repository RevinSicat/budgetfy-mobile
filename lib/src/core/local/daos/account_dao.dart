import 'package:drift/drift.dart';
import '../local_database.dart';

part 'account_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountDao extends DatabaseAccessor<LocalDatabase> with _$AccountDaoMixin {
    AccountDao(super.db);

    /// [GET]: Retrieve all non-deleted Accounts ordered by {name}
    Future<List<AccountData>> getAllAccounts() {
        return (
            select(accounts)
                ..where((t) => t.isDeleted.equals(false))
                ..orderBy([(t) => OrderingTerm.asc(t.name)])
        ).get();
    }

    /// [GET]: Retrieve Account by {id}
    Future<AccountData?> getAccountById(String id) {
        return (
            select(accounts)
                ..where((t) => t.id.equals(id))
        ).getSingleOrNull();
    }

    /// [GET]: Retrieve all Accounts pending sync to Supabase
    Future<List<AccountData>> getAllPendingAccounts() {
        return (
            select(accounts)
                ..where((t) => t.pendingSync.equals(true))
        ).get();
    }

    /// [POST]: Create Account
    Future<void> saveAccount(AccountsCompanion entry) {
        return into(accounts).insertOnConflictUpdate(entry);
    }

    /// [PUT]: Update Account
    Future<void> updateAccount(AccountsCompanion entry) {
        return (
            update(accounts)
                ..where((t) => t.id.equals(entry.id.value))
        ).write(entry);
    }

    /// [PUT]: Mark Account as synced by {id}
    Future<void> updateAccountAsSyncedById(String id) {
        return (
            update(accounts)
                ..where((t) => t.id.equals(id))
        ).write(const AccountsCompanion(
            pendingSync: Value(false),
        ));
    }

    /// [DELETE]: Mark Account as deleted by {id}
    Future<void> softDeleteAccountById(String id) {
        return (
            update(accounts)
                ..where((t) => t.id.equals(id))
        ).write(AccountsCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(DateTime.now()),
            pendingSync: const Value(true),
        ));
    }
}