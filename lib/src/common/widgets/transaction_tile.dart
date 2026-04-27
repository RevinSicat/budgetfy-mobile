import 'package:flutter/material.dart';
import '../../features/transaction/transaction.dart';
import '../../features/category/category.dart';
import '../../common/utils/color_utility.dart';
import '../../common/widgets/transaction_form.dart';
import '../../common/widgets/tool_tip.dart';

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
            
        final accountColor = transaction.account != null
            ? hexToColor(transaction.account!.color)
            : Colors.grey;

        final isIncome = transaction.category?.type == CategoryType.income;
        final iconKey = GlobalKey();

        return GestureDetector(
            onTap: () {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (_) => TransactionForm(transaction: transaction),
                );
            },
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                padding: const EdgeInsets.all(12), // Added padding for the custom Row layout
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
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        // Left Side: 2 Rows wrapped in Expanded
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    // Row 1: Category Color and Name
                                    Row(
                                        children: [
                                            Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                    color: categoryColor,
                                                    shape: BoxShape.circle,
                                                ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                                child: Text(
                                                    transaction.category?.name ?? 'Uncategorized',
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                ),
                                            ),
                                        ],
                                    ),
                                    
                                    const SizedBox(height: 6),
                                    
                                    // Row 2: Account Badge
                                    Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        margin: const EdgeInsets.only(left: 20),
                                        decoration: BoxDecoration(
                                            color: accountColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                                color: accountColor.withOpacity(0.5),
                                                width: 1,
                                            ),
                                        ),
                                        child: Text(
                                            transaction.account?.name ?? 'No Account',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: accountColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                        ),
                                    ),
                                ],
                            ),
                        ),
                        if (transaction.note.isNotEmpty) ...[
                            GestureDetector(
                                key: iconKey,
                                onTap: () {
                                    final preview = transaction.note.length > 50
                                            ? '${transaction.note.substring(0, 50)}...'
                                            : transaction.note;
                                    showToolTip(context, preview, iconKey);
                                },
                                child: Icon(
                                    Icons.article,
                                    size: 18,
                                    color: Colors.grey.shade600
                                )
                            ),
                            const SizedBox(width: 8),
                        ],
                        const SizedBox(width: 12),
                        // Right Side: Amount
                        Text(
                            '${isIncome ? '+' : ''}${transaction.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                                color: isIncome ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                            ),
                        ),
                    ],
                ),
            )
        );
    }
}