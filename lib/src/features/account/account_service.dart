import 'package:drift/drift.dart';
import '../../core/local/local_database.dart';
import '../../core/sync/sync_service.dart';
import 'package:uuid/uuid.dart';
import 'account.dart';

class AccountService {
    final LocalDatabase _db;
    final SyncService _syncService;

    AccountService(this._db) : _syncService = SyncService(_db);

    /// [GET]: Retreives Account List
    Future<List<Account>> getAllList() async {
        final rows = await _db.accountDao.getAllAccounts();
        return rows.map((row) => Account(
            id: row.id,
            name: row.name,
            color: row.color
        )).toList();
    }

    /// [POST]: Create Account
    Future<void> save(Account account) async {
        final accountId = account.id.isEmpty
            ? const Uuid().v4()
            : account.id;

        final companion = AccountsCompanion(
            id: Value(accountId),
            name: Value(account.name),
            color: Value(account.color),
            updatedAt: Value(DateTime.now()),
            pendingSync: const Value(true)
        );

        await _db.accountDao.saveAccount(companion);

        await _syncService.writeToOutbox(
            tableName: 'accounts', 
            recordId: accountId, 
            operation: 'create', 
            payload: account.toJson()
                ..['id'] = accountId
                ..['updated_at'] = DateTime.now().toIso8601String()
        );
    }

    /// [PUT]: Update Account
    Future<void> update(Account account) async {
        final updatedAt = DateTime.now();

        await _db.accountDao.updateAccount(AccountsCompanion(
            id: Value(account.id),
            name: Value(account.name),
            color: Value(account.color),
            updatedAt: Value(updatedAt),
            pendingSync: const Value(true)
        ));

        await _syncService.writeToOutbox(
            tableName: 'accounts', 
            recordId: account.id, 
            operation: 'update', 
            payload: account.toJson()
                ..['updated_at'] = updatedAt.toIso8601String()
        );
    }

    /// [DELETE]: Soft delete Account by {id}
    Future<void> deleteById(String id) async {
        await _db.accountDao.softDeleteAccountById(id);

        await _syncService.writeToOutbox(
            tableName: 'accounts', 
            recordId: id, 
            operation: 'delete', 
            payload: {
                'id': id,
                'updated_at': DateTime.now().toIso8601String()
            }
        );
    }
}