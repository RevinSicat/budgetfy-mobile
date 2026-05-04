import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../features/account/account.dart';
import '../../../features/transaction/transaction_provider.dart';
import '../../utils/color_utility.dart';
import '../forms/account_form.dart';

class AccountCard extends ConsumerWidget {
    final Account account;
    const AccountCard({
        super.key, 
        required this.account
    });

    void openEditForm(BuildContext context) {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16)
                ),
            ),
            builder: (_) => AccountForm(account: account)
        );
    }

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final balance = ref.watch(getTotalTransactionAmmountByAccountIdProvider(account.id));
        final uuidLast4 = account.id.substring(account.id.length - 4);
        final theme = Theme.of(context);

        return GestureDetector(
            onTap: () => openEditForm(context),
            child: Container(
                width: 260,
                height: 120,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: hexToColor(account.color),
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
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Expanded(
                                    child: Text(
                                        account.name,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                            fontSize: AppFontSize.bodyLg,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1
                                    )
                                ),
                                Container(
                                    width: 36,
                                    height: 24,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(6),
                                    ),
                                ),
                            ],
                        ),
                        const Spacer(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                                balance.when(
                                    data: (amount) => Text(
                                        amount.toStringAsFixed(2),
                                        style: theme.textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                            fontSize: AppFontSize.headline,
                                        )
                                    ),
                                    loading: () => const SizedBox(
                                        height: 16, width: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    error: (e, _) => const Text('-'),
                                ),
                            ],
                        ),
                        const Spacer(),
                        Text(
                            '**** **** **** $uuidLast4',
                            style: theme.textTheme.labelSmall?.copyWith(color: Colors.white70),
                        ),
                    ],
                ),
            ),
        );
    }
}