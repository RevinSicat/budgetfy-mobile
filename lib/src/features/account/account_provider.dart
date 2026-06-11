import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/local/local_database_provider.dart';
import 'account.dart';
import 'account_service.dart';

final accountServiceProvider = Provider<AccountService>((ref) {
    return AccountService(ref.watch(localDatabaseProvider));
});

final getAllAccountListProvider = FutureProvider<List<Account>>((ref) async {
    return ref.read(accountServiceProvider).findAll();
});