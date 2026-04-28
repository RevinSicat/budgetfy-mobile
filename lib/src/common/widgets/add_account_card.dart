import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'account_form.dart';

class AddAccountCard extends ConsumerWidget {
    const AddAccountCard({super.key});

    void openAccountForm(BuildContext context) {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => const AccountForm(),
        );
    }

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final theme = Theme.of(context);

        return GestureDetector(
            onTap: () => openAccountForm(context),
            child: Container(
                width: 120,
                height: 120,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(4, 4),
                            blurRadius: 6,
                            spreadRadius: 1,
                        )
                    ],
                ),
                child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(Icons.add, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Add Account', style: TextStyle(color: Colors.grey)),
                    ],
                ),
            ),
        );
    }
}