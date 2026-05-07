import 'package:budgetfy/src/features/category/category.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/connection/supabase_config.dart';
import '../dashboard/category_chart_data.dart';
import '../transaction/transaction.dart';

class TransactionService {
    final _sbdb = SupabaseConfig.client;

    /// Transaction List ==========================================================================
    /// [GET]: Retreives Transaction List
    Future<List<Transaction>> getAllbyPagination({int page = 0, int limit = 20}) async {
        try {
            final int from = page * limit;
            final int to = from + limit - 1;

            final response = await _sbdb.from('transactions')
                .select('*, accounts(*), categories(*), subcategories(*)')
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
                .select('*, accounts(*), categories(*), subcategories(*)');
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

    /// [GET]: Retrieve Transactions by {Year, Month} with pagination
    Future<List<Transaction>> getByYearAndMonth({required int year,required int month,
            int page = 0, int limit = 20}) async {
        try {
            final startDate = DateTime(year, month, 1);
            final endDate = DateTime(year, month + 1, 1).subtract(const Duration(milliseconds: 1));

            final int from = page * limit;
            final int to = from + limit - 1;

            final response = await _sbdb
                .from('transactions')
                .select('*, accounts(*), categories(*), subcategories(*)')
                .gte('date', startDate.toIso8601String())
                .lte('date', endDate.toIso8601String())
                .order('date', ascending: false)
                .range(from, to);

            return (response as List)
                .map((json) => Transaction.fromJson(json))
                .toList();
        } catch (e) {
            print('[Error fetching transactions by year/month]: $e');
            rethrow;
        }
    }

    /// [GET]: Retrieve Transactions grouped by month for a given year
    Future<Map<int, List<Transaction>>> getGroupByMonthByYear(int year) async {
        try {
            final startDate = DateTime(year, 1, 1);
            final endDate = DateTime(year + 1, 1, 1).subtract(const Duration(milliseconds: 1));

            final response = await _sbdb
                .from('transactions')
                .select('*, accounts(*), categories(*), subcategories(*)')
                .gte('date', startDate.toIso8601String())
                .lte('date', endDate.toIso8601String())
                .order('date', ascending: false);

            final transactions = (response as List)
                .map((json) => Transaction.fromJson(json))
                .toList();

            final Map<int, List<Transaction>> grouped = {};
            for (final t in transactions) {
                final month = t.date.month;
                grouped.putIfAbsent(month, () => []).add(t);
            }

            return grouped;
        } catch (e) {
            print('[Error fetching transactions by year grouped by month]: $e');
            rethrow;
        }
    }

    /// Transaction ===============================================================================
    /// [GET]: Retreive Transaction by {Id}
    Future<Transaction> getById(String id) async {
        try {
            final response = await _sbdb.from('transactions')
                .select('*, accounts(*), categories(*), subcategories(*)')
                .eq('id', id)
                .single();
            return Transaction.fromJson(response);
        } catch (e) {
            print('[Error fetching transaction]: $e');
            rethrow;
        }
    }

    /// Map String double =========================================================================
    /// [GET]: Retreive Net Totals
    Future<Map<String, double>> getNetTotals() async {
        try {
            double netWorth = 0.00;
            double netIncome = 0.00;
            double netExpense = 0.00;
            final response = await _sbdb.from('transactions')
                .select('amount');

            for (var row in response as List) {
                final double amount = (row['amount'] as num).toDouble();

                if (amount >= 0) {
                    netIncome += amount;
                } else {
                    netExpense += amount.abs();
                }
            }
            netWorth = netIncome - netExpense;
            return {
                'net_worth': double.parse(netWorth.toStringAsFixed(2)),
                'net_income': double.parse(netIncome.toStringAsFixed(2)),
                'net_expense': double.parse(netExpense.toStringAsFixed(2))
            };
        } catch (e) {
            print('[Error fetching transaction net totals]: $e');
            rethrow;
        }
    }

    /// [GET]: Retrieve Transaction Category Amount Sum by {month, year}
    Future<List<CategoryChartData>> getCategoryAmountSumByMonthAndYear({required int month, required int year,}) async {
        try {
            final startDate = DateTime(year, month, 1);
            final endDate = DateTime(year, month + 1, 1)
                .subtract(const Duration(milliseconds: 1));

            final response = await _sbdb
                .from('transactions')
                .select('amount, categories(id, name, color, type)')
                .gte('date', startDate.toIso8601String())
                .lte('date', endDate.toIso8601String());

            final Map<String, Map<String, dynamic>> grouped = {};

            for (var row in response as List) {
                final cat = row['categories'] as Map<String, dynamic>;
                final id = cat['id'] as String;
                final amount = (row['amount'] as num).toDouble().abs();

                if (!grouped.containsKey(id)) {
                    grouped[id] = {'meta': cat, 'total': 0.0};
                }
                grouped[id]!['total'] = (grouped[id]!['total'] as double) + amount;
            }

            return grouped.values.map((entry) {
                final meta = entry['meta'] as Map<String, dynamic>;
                return CategoryChartData(
                    categoryId: meta['id'] as String,
                    name: meta['name'] as String,
                    color: meta['color'] as String,
                    type: CategoryType.values.firstWhere(
                        (e) => e.name == meta['type'],
                        orElse: () => CategoryType.expense,
                    ),
                    total: entry['total'] as double,
                );
            }).toList();
        } catch (e) {
            print('[Error fetching category chart data]: $e');
            rethrow;
        }
    }

    /// double ====================================================================================
    /// [GET]: Retreive Transaction Amount Sum
    Future<double> getAmountSum() async {
        try {
            final response = await _sbdb.from('transactions')
                .select('amount');

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

    /// [GET]: Retreive Transaction Amount Sum by accountId
    Future<double> getAmountSumByAccountId(String accountId) async {
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
            print('[Error fetching transaction amount sum by account]: $e');
            rethrow;
        }
    }

    /// [GET]: Retreive Transaction Amount Sum by categoryId
    Future<double> getAmountSumByCategoryId(String categoryId) async {
        try {
            final response = await _sbdb.from('transactions')
                .select('amount')
                .eq('category_id', categoryId);

            double amountSum = 0.0;

            for (var row in response as List) {
                amountSum += (row['amount'] as num).toDouble();
            }

            return amountSum;
        } catch (e) {
            print('[Error fetching transaction amount sum by category]: $e');
            rethrow;
        }
    }

    /// int =======================================================================================
    /// [GET]: Retreive Transaction Count by accountId
    Future<int> getCountByAccountId(String accountId) async {
        try {
            final response = await _sbdb
                .from('transactions')
                .select('id')
                .eq('account_id', accountId)
                .count(CountOption.exact);

            return response.count;
        } catch (e) {
            print('[Error fetching transaction count]: $e');
            rethrow;
        }
    }

    /// [GET]: Retreive Transaction Count by categoryId
    Future<int> getCountByCategoryId(String categoryId) async {
        try {
            final response = await _sbdb
                .from('transactions')
                .select('id')
                .eq('category_id', categoryId)
                .count(CountOption.exact);

            return response.count;
        } catch (e) {
            print('[Error fetching transaction count]: $e');
            rethrow;
        }
    }
    
    /// void Create, Update, Delete ===============================================================
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

    /// [PUT]: Update Transaction Amount By Category
    Future<void> updateAmountByCategory(String categoryId) async {
        try {
            final response = await _sbdb
                .from('transactions')
                .select('id, amount')
                .eq('category_id', categoryId);

            final transactions = response as List;
            if (transactions.isEmpty) return;
            for (var row in transactions) {
                final double currentAmount = (row['amount'] as num).toDouble();
                await _sbdb
                    .from('transactions')
                    .update({'amount': currentAmount * -1})
                    .eq('id', row['id']);
            }
        } catch (e) {
            print('[Error inverting transaction amounts]: $e');
            rethrow;
        }
    }

    /// [DELETE]: Delete Transaction
    Future<void> deleteById(String id) async {
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