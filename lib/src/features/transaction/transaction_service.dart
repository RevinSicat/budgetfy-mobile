import '../../core/connection/supabase_config.dart';
import '../transaction/transaction.dart';

class TransactionService {
    final _sbdb = SupabaseConfig.client;

    /// [GET]: Retreives Transaction List
    Future<List<Transaction>> getAllbyPagination({int page = 0, int limit = 20}) async {
        try {
            final int from = page * limit;
            final int to = from + limit - 1;

            final response = await _sbdb.from('transactions')
                .select('*, accounts(*), categories(*)')
                .order('date', ascending: false)
                .range(from, to);

            return (response as List)
                .map((json) => Transaction.fromJson(json))
                .toList(); 
        } catch (e) {
            print('[Error fetching transaction list]: $e');
            rethrow;
        }
    }

    /// [GET]: Retrieve Transactions List by Specification
    Future<List<Transaction>> getBySpecification({String? accountId, String? categoryId, TransactionType? transactionType,
            DateTime? startDate, DateTime? endDate, int page = 0, int limit = 20,}) async {
        try {
            var query = _sbdb.from('transactions')
                .select('*, accounts(*), categories(*)');
            if (accountId != null) {
                query = query.eq('account_id', accountId);
            }
            if (categoryId != null) {
                query = query.eq('category_id', categoryId);
            }
            if (transactionType != null) {
                query = query.eq('transaction_type', transactionType.name);
            }
            if (startDate != null) {
                query = query.gte('date', startDate.toIso8601String());
            }
            if (endDate != null) {
                query = query.lte('date', endDate.toIso8601String());
            }

            final int from = page * limit;
            final int to = from + limit - 1;
            
            final response = await query
                .order('date', ascending: false)
                .range(from, to);

            return (response as List)
                .map((json) => Transaction.fromJson(json))
                .toList(); 
        } catch (e) {
            print('[Error fetching transactions by filter]: $e');
            rethrow;
        }
    }

    /// [GET]: Retreive Transaction by {Id}
    Future<Transaction> getById(String id) async {
        try {
            final response = await _sbdb.from('transactions')
                .select('*, accounts(*), categories(*)')
                .eq('id', id)
                .single();
            return Transaction.fromJson(response);
        } catch (e) {
            print('[Error fetching transaction]: $e');
            rethrow;
        }
    }

    /// [GET]: Retreive Transaction Amount Sum by accountId
    Future<double> getTransactionAmmountByAccountId(String accountId) async {
        try {
            final response = await _sbdb.from('transactions')
                .select('amount')
                .eq('account_id', accountId);

            double amountSum = 0.0;

            for (var row in response as List) {
                amountSum += (row['amount'] as num).toDouble();
            }

            return amountSum;
        } catch (e) {
            print('[Error fetching transaction amount sum]: $e');
            rethrow;
        }
    }

    /// [POST]: Create Transaction
    Future<void> save(Transaction transaction) async {
        try {
            await _sbdb.from('transactions')
                .insert(transaction.toJson());
        } catch (e) {
            print('[Error creating transaction]: $e');
            rethrow;
        }
    }

    /// [PUT]: Update Transaction
    Future<void> update(Transaction transaction) async {
        try {
            await _sbdb.from('transactions')
                .update(transaction.toJson())
                .eq('id', transaction.id);
        } catch (e) {
            print('[Error updating transaction]: $e');
            rethrow;
        }
    }

    /// [DELETE]: Delete Transaction
    Future<void> delete(String id) async {
        try {
            await _sbdb.from('transactions')
                .delete()
                .eq('id', id);
        } catch (e) {
            print('[Error deleting transaction]: $e');
            rethrow;
        }
    }
}