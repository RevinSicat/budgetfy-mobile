import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/local/local_database_provider.dart';
import 'account.dart';
import 'account_service.dart';

final accountServiceProvider = Provider<AccountService>((ref) {
    final db = ref.watch(localDatabaseProvider);
    return AccountService(db);
});

final getAllAccountListProvider = FutureProvider<List<Account>>((ref) async {
    final service = ref.read(accountServiceProvider);
    return service.getAllList();
});