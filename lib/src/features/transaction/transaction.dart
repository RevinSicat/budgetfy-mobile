import '../account/account.dart';
import '../category/category.dart';

enum TransactionType { Default, Upcoming, Subscription, Lent, Borrowed }

class Transaction {
    /// [Fields]:
    final String id;
    final String accountId;
    final String categoryId;
    final Account? account;
    final Category? category; 
    final double amount;
    final DateTime date;
    final TransactionType transactionType;
    final String note;
    final DateTime createdAt;
    final DateTime updatedAt;

    /// [Constructor]:
    Transaction({
        required this.id,
        required this.accountId,
        required this.categoryId,
        this.account,
        this.category,
        required this.amount,
        required this.date,
        required this.transactionType,
        required this.note,
        required this.createdAt,
        required this.updatedAt,
    });

    /// [Converter]: Json -> Transaction Entity
    factory Transaction.fromJson(Map<String, dynamic> json) {
        return Transaction(
            id: json['id'],
            accountId: json['account_id'],
            categoryId: json['category_id'],
            account: json['accounts'] != null ? Account.fromJson(json['accounts']) : null,
            category: json['categories'] != null ? Category.fromJson(json['categories']) : null,
            amount: (json['amount'] as num).toDouble(),
            date: DateTime.parse(json['date']),
            transactionType: TransactionType.values.firstWhere(
                (e) => e.name == json['transaction_type'],
                orElse: () => TransactionType.Default,
            ),
            note: json['note'] ?? '',
            createdAt: DateTime.parse(json['created_at']),
            updatedAt: DateTime.parse(json['updated_at']),
        );
    }

    /// [Converter]: Transaction Entity -> Json
    Map<String, dynamic> toJson() {
        return {
            if (id.isNotEmpty) 'id': id,
            'account_id': accountId,
            'category_id': categoryId,
            'amount': amount,
            'date': date.toIso8601String(),
            'transaction_type': transactionType.name,
            'note': note,
            'created_at': createdAt.toIso8601String(),
            'updated_at': updatedAt.toIso8601String(),
        };
    }
}