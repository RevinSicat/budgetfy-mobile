import '../account/account.dart';
import '../category/category.dart';
import '../subcategory/subcategory.dart';

enum TransactionType { Default, Upcoming, Subscription, Lent, Borrowed }

class Transaction {
    /// [Fields]:
    final String id;
    final String accountId;
    final String categoryId;
    final String? subcategoryId;  
    final Account? account;
    final Category? category; 
    final Subcategory? subcategory;
    final double amount;
    final DateTime date;
    final TransactionType transactionType;
    final String note;

    /// [Constructor]:
    Transaction({
        required this.id,
        required this.accountId,
        required this.categoryId,
        this.subcategoryId,
        this.account,
        this.category,
        this.subcategory,
        required this.amount,
        required this.date,
        required this.transactionType,
        required this.note,
    });

    /// [Converter]: Json -> Transaction Entity
    factory Transaction.fromJson(Map<String, dynamic> json) {
        return Transaction(
            id: json['id'],
            accountId: json['account_id'],
            categoryId: json['category_id'],
            subcategoryId: json['subcategory_id'],
            account: json['accounts'] != null ? Account.fromJson(json['accounts']) : null,
            category: json['categories'] != null ? Category.fromJson(json['categories']) : null,
            subcategory: json['subcategories'] != null ? Subcategory.fromJson(json['subcategories']) : null,
            amount: (json['amount'] as num).toDouble(),
            date: DateTime.parse(json['date']),
            transactionType: TransactionType.values.firstWhere(
                (e) => e.name == json['transaction_type'],
                orElse: () => TransactionType.Default,
            ),
            note: json['note'] ?? ''
        );
    }

    /// [Converter]: Transaction Entity -> Json
    Map<String, dynamic> toJson() {
        return {
            if (id.isNotEmpty) 'id': id,
            'account_id': accountId,
            'category_id': categoryId,
            if (subcategoryId != null) 'subcategory_id': subcategoryId,
            'amount': amount,
            'date': date.toIso8601String(),
            'transaction_type': transactionType.name,
            'note': note,
        };
    }
}