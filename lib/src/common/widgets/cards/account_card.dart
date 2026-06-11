import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

        return GestureDetector(
            onTap: () => openEditForm(context),
            child: LayoutBuilder(
                builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;
                    final nameFontSize = (w * 0.1).clamp(12.0, 20.0);
                    final amountFontSize = (w * 0.175).clamp(14.0, 26.0);
                    final labelFontSize = (w * 0.15).clamp(9.0,  13.0);
                    final chipW = (w * 0.225).clamp(28.0, 48.0);
                    final chipH = (h * 0.2).clamp(16.0, 28.0);
                    final padding = (w * 0.062).clamp(10.0, 20.0);
                    final radius = (w * 0.046).clamp(8.0,  16.0);

                    return Container(
                        padding: EdgeInsets.all(padding),
                        decoration: BoxDecoration(
                            color: hexToColor(account.color),
                            borderRadius: BorderRadius.circular(radius),
                            boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    offset: const Offset(4, 4),
                                    blurRadius: 6,
                                    spreadRadius: 1
                                )
                            ]
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                // ── Row 1: name + decorative chip ──────────────────────
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        Expanded(
                                            child: Text(
                                                account.name,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: nameFontSize,
                                                    fontWeight: FontWeight.w600
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1
                                            )
                                        ),
                                        Container(
                                            width:  chipW,
                                            height: chipH,
                                            decoration: BoxDecoration(
                                                color:        Colors.white.withOpacity(0.35),
                                                borderRadius: BorderRadius.circular(6)
                                            )
                                        )
                                    ]
                                ),

                                const Spacer(),

                                // ── Row 2: balance ─────────────────────────────────────
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: balance.when(
                                        data: (amount) => Text(
                                            '₱${amount.toStringAsFixed(2)}',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: amountFontSize,
                                                fontWeight: FontWeight.bold
                                            )
                                        ),
                                        loading: () => SizedBox(
                                            height: amountFontSize,
                                            width: amountFontSize,
                                            child: const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white70
                                            )
                                        ),
                                        error: (_, __) => Text(
                                            '—',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: amountFontSize,
                                            )
                                        )
                                    )
                                ),

                                const Spacer(),

                                // ── Row 3: masked card number ──────────────────────────
                                Text(
                                    '**** **** **** $uuidLast4',
                                    style: TextStyle(
                                        color:      Colors.white70,
                                        fontSize:   labelFontSize,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.2
                                    )
                                )
                            ]
                        )
                    );
                }
            )
        );
    }
}