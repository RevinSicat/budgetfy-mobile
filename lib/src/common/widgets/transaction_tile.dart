import 'package:flutter/material.dart';
import '../../../src/features/transaction/transaction.dart';
import '../../../src/features/category/category.dart';
import '../../common/utils/color_utility.dart';

class TransactionTile extends StatelessWidget {
    final Transaction transaction;
    const TransactionTile({
        super.key,
        required this.transaction
    });

    @override
    Widget build(BuildContext context) {
        final categoryColor = transaction.category != null 
            ? hexToColor(transaction.category!.color)
            : Colors.grey;
        final isIncome = transaction.category?.type == CategoryType.income;

        return Container(
            margin: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(2, 2),
                        blurRadius: 2,
                        spreadRadius: 1,
                    )
                ]
            ),
            child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: categoryColor,
                    radius: 6,
                ),
                title: Text(
                    transaction.category?.name ?? 'Uncategorized'
                ),
                trailing: Text(
                    '${isIncome ? '+' : ''}${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: isIncome ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                    ),
                ),
            )
        );
    }
}