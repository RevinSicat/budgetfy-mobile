import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/local/local_database.dart';
import '../../core/sync/sync_service.dart';
import 'account.dart';

class AccountService {
    final LocalDatabase _db;
    final SyncService _sync;

    AccountService(this._db) : _sync = SyncService(_db);

    /// [GET]: Retrieve all non-deleted Accounts
    Future<List<Account>> findAll() async {
        final rows = await _db.accountDao.getAllAccounts();
        return rows.map((row) => Account(
            id: row.id,
            name: row.name,
            color: row.color,
        )).toList();
    }

    /// [POST]: Create Account
    Future<void> save(Account account) async {
        final id = account.id.isEmpty ? const Uuid().v4() : account.id;

        await _db.accountDao.saveAccount(AccountsCompanion(
            id: Value(id),
            name: Value(account.name),
            color: Value(account.color),
            updatedAt: Value(DateTime.now().toUtc())
        ));

        await _sync.pushRecordNow();
    }

    /// [PUT]: Update Account
    Future<void> update(Account account) async {
        await _db.accountDao.updateAccount(AccountsCompanion(
            id: Value(account.id),
            name: Value(account.name),
            color: Value(account.color),
            updatedAt: Value(DateTime.now().toUtc()),
            pendingSync: const Value(true)
        ));

        await _sync.pushRecordNow();
    }

    /// [DELETE]: Soft-delete Account by {id}
    Future<void> deleteById(String id) async {
        await _db.accountDao.softDeleteAccountById(id);
        await _sync.pushRecordNow();
    }
}