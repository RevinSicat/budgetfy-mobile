import 'package:drift/drift.dart';
import '../../core/local/local_database.dart';
import 'package:uuid/uuid.dart';
import 'account.dart';

class AccountService {
    final LocalDatabase _db;

    AccountService(this._db);

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

        await _db.accountDao.saveAccount(AccountsCompanion(
            id: Value(accountId),
            name: Value(account.name),
            color: Value(account.color),
            updatedAt: Value(DateTime.now()),
        ));
    }

    /// [PUT]: Update Account
    Future<void> update(Account account) async {
        await _db.accountDao.updateAccount(AccountsCompanion(
            id: Value(account.id),
            name: Value(account.name),
            color: Value(account.color),
            updatedAt: Value(DateTime.now())
        ));
    }

    /// [DELETE]: Soft delete Account by {id}
    Future<void> deleteById(String id) async {
        await _db.accountDao.softDeleteAccountById(id);
    }
}