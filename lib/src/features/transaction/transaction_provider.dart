import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction.dart';
import 'transaction_service.dart';

final transactionServiceProvider = Provider<TransactionService>((ref) {
    return TransactionService();
});

final transactionListProvider = FutureProvider<List<Transaction>>((ref) {
    final service = ref.read(transactionServiceProvider);
    return service.getAllbyPagination();
});