import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../features/transaction/transaction.dart';
import 'transaction_tile.dart';

class TransactionGroupSection extends StatelessWidget {
    final DateTime date;
    final List<Transaction> transactions;

    const TransactionGroupSection({
        super.key,
        required this.date,
        required this.transactions,
    });

    @override
    Widget build(BuildContext context) {
        return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
                formatDate(date),
                style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                ),
            ),
            ),
            ...transactions.map((trn) => TransactionTile(transaction: trn)),
        ],
        );
    }

    String formatDate(DateTime date) {
        final formatter = DateFormat('MMMM d, yyyy'); 
        return formatter.format(date);
    }
}