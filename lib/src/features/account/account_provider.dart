import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'account.dart';
import 'account_service.dart';

final accountServiceProvider = Provider<AccountService>((ref) {
    return AccountService();
});

final getAllAccountListProvider = FutureProvider<List<Account>>((ref) async {
    final service = ref.read(accountServiceProvider);
    return service.getAllList();
});