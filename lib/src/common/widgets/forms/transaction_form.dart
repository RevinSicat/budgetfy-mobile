import 'package:budgetfy/src/common/utils/color_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/transaction/transaction.dart';
import '../../../features/transaction/transaction_provider.dart';
import '../../../features/account/account_provider.dart';
import '../../../features/category/category_provider.dart';
import '../../../features/account/account.dart';
import '../../../features/category/category.dart';
import '../../utils/dropdown_item.dart';

class TransactionForm extends ConsumerStatefulWidget {
    final Transaction? transaction;
    const TransactionForm({
        super.key,
        this.transaction
    });

    @override
    ConsumerState<TransactionForm> createState() => TransactionFormState();
}

class TransactionFormState extends ConsumerState<TransactionForm> {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    Account? selectedAccount;
    Category? selectedCategory;
    TransactionType selectedType = TransactionType.Default;
    DateTime selectedDate = DateTime.now();
    bool isLoading = false;

    String? amountError;
    String? accountError;
    String? categoryError;
    bool hasSubmitAttempt = false;

    @override
    void initState() {
        super.initState();
        if (widget.transaction != null) {
            final trn = widget.transaction!;
            amountController.text = trn.amount < 0
                ? (trn.amount * -1).toString()
                : trn.amount.toString();
            noteController.text = trn.note;
            selectedType = trn.transactionType;
            selectedDate = trn.date;
        }
    }

    @override
    void dispose() {
        amountController.dispose();
        noteController.dispose();
        super.dispose();
    }

    bool validate() {
        String? newAmountError;
        String? newAccountError;
        String? newCategoryError;

        final amountText = amountController.text.trim();
        if (amountText.isEmpty) {
            newAmountError = 'Amount is required.';
        } else {
            final parsed = double.tryParse(amountText);
            if (parsed == null || parsed <= 0) {
                newAmountError = 'Amount must be greater than 0.';
            }
        }

        if (selectedAccount == null) {
            newAccountError = 'Please select an account.';
        }

        if (selectedCategory == null) {
            newCategoryError = 'Please select a category.';
        }

        setState(() {
            amountError = newAmountError;
            accountError = newAccountError;
            categoryError = newCategoryError;
        });

        return newAmountError == null &&
               newAccountError == null &&
               newCategoryError == null;
    }

    Future<void> pickDate() async {
        final pickedDate = await showDatePicker(
            context: context, 
            initialDate: selectedDate,
            firstDate: DateTime(2000), 
            lastDate: DateTime(2100)
        );
        if (pickedDate != null) {
            setState(() {
                selectedDate = pickedDate;
            });
        }
    }

    Future<void> submit() async {
        setState(() => hasSubmitAttempt = true);
        if (!validate()) return;

        setState(() => isLoading = true);

        try {
            final service = ref.read(transactionServiceProvider);
            final amount = double.parse(amountController.text.trim());
            final finalAmount = selectedCategory!.type == CategoryType.income
                ? amount
                : amount * -1;

            final transactionData = Transaction(
                id: widget.transaction?.id ?? '',
                accountId: selectedAccount!.id,
                categoryId: selectedCategory!.id,
                amount: finalAmount,
                date: selectedDate,
                transactionType: selectedType,
                note: noteController.text.trim()
            );

            if (widget.transaction == null) {
                await service.save(transactionData);
            } else {
                await service.update(transactionData);
            }

            ref.invalidate(getAllTransactionByPaginationProvider);
            ref.invalidate(getTotalTransactionAmmountByAccountIdProvider);
            if (mounted) Navigator.pop(context);
        } catch (e) {
            setState(() => isLoading = false);
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                );
            }
        }
    }

    Future<void> deleteTransaction() async {
        final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
                title: const Text('Delete Transaction'),
                content: const Text('Are you sure? This cannot be undone.'),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')
                    ),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete')
                    )
                ]
            )
        );

        if (confirm != true) return;

        setState(() => isLoading = true);
        try {
            await ref.read(transactionServiceProvider).deleteById(widget.transaction!.id);
            ref.invalidate(getAllTransactionByPaginationProvider);
            ref.invalidate(getTotalTransactionAmmountByAccountIdProvider);
            if (mounted) Navigator.pop(context);
        } catch (e) {
            setState(() => isLoading = false);
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'))
                );
            }
        }
    }

    // Reusable Bootstrap-style error message widget
    Widget errorText(String message) {
        return Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
                children: [
                    const Icon(Icons.error_outline, size: 14, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                        message,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500
                        )
                    )
                ]
            )
        );
    }

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        final accountList = ref.watch(getAllAccountListProvider);
        final categoryList = ref.watch(getAllCategoryListProvider);
        final isEdit = widget.transaction != null;

        return accountList.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (accounts) => categoryList.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (categories) {
                    if (isEdit && selectedAccount == null) {
                        selectedAccount = accounts.firstWhere(
                            (a) => a.id == widget.transaction!.accountId,
                            orElse: () => accounts.first
                        );
                    }
                    if (isEdit && selectedCategory == null) {
                        selectedCategory = categories.firstWhere(
                            (c) => c.id == widget.transaction!.categoryId,
                            orElse: () => categories.first
                        );
                    }

                    return SingleChildScrollView(
                        padding: EdgeInsets.only(
                            left: 16, right: 16, top: 24,
                            bottom: MediaQuery.of(context).viewInsets.bottom + 24
                        ),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        Text(
                                            isEdit 
                                                ? 'Edit Transaction' 
                                                : 'Add Transaction',
                                            style: theme.textTheme.titleLarge,
                                        ),
                                        if (isEdit)
                                            IconButton(
                                                onPressed: isLoading ? null : deleteTransaction,
                                                icon: const Icon(Icons.delete, color: Colors.red)
                                            )
                                    ]
                                ),
                                const SizedBox(height: 16),

                                // Amount
                                TextField(
                                    controller: amountController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                                    ],
                                    style: theme.textTheme.bodyLarge,
                                    onChanged: (_) {
                                        if (hasSubmitAttempt) validate();
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'Amount',
                                        prefixText: '₱ ',
                                        border: const OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: amountError != null 
                                                    ? Colors.red 
                                                    : theme.dividerColor,
                                                width: amountError != null 
                                                    ? 2 
                                                    : 1
                                            )
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: amountError != null 
                                                    ? Colors.red 
                                                    : theme.colorScheme.primary,
                                                width: 2
                                            )
                                        )
                                    )
                                ),
                                if (amountError != null) errorText(amountError!),
                                const SizedBox(height: 16),

                                // Date
                                Text(
                                    'Date',
                                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                    onTap: pickDate,
                                    child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                        decoration: BoxDecoration(
                                            border: Border.all(color: theme.dividerColor),
                                            borderRadius: BorderRadius.circular(4)
                                        ),
                                        child: Text(
                                            '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                                            style: theme.textTheme.bodyLarge
                                        )
                                    )
                                ),
                                const SizedBox(height: 16),

                                Text(
                                    'Account',
                                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<Account>(
                                    value: selectedAccount,
                                    decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: accountError != null 
                                                    ? Colors.red 
                                                    : theme.dividerColor,
                                                width: accountError != null 
                                                    ? 2 
                                                    : 1,
                                            )
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: accountError != null ? Colors.red : theme.colorScheme.primary,
                                                width: 2
                                            )
                                        )
                                    ),
                                    items: accounts.map((acc) => DropdownMenuItem(
                                        value: acc,
                                        child: dropdownItem(context, hexToColor(acc.color), acc.name)
                                    )).toList(),
                                    onChanged: (val) {
                                        setState(() {
                                            selectedAccount = val;
                                            if (hasSubmitAttempt) validate();
                                        });
                                    }
                                ),
                                if (accountError != null) errorText(accountError!),
                                const SizedBox(height: 16),

                                Text(
                                    'Category',
                                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<Category>(
                                    value: selectedCategory,
                                    decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: categoryError != null 
                                                    ? Colors.red 
                                                    : theme.dividerColor,
                                                width: categoryError != null 
                                                    ? 2 
                                                    : 1
                                            )
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: categoryError != null 
                                                    ? Colors.red 
                                                    : theme.colorScheme.primary,
                                                width: 2
                                            )
                                        )
                                    ),
                                    items: categories.map((ctg) => DropdownMenuItem(
                                        value: ctg,
                                        child: dropdownItem(context, hexToColor(ctg.color), ctg.name)
                                    )).toList(),
                                    onChanged: (val) {
                                        setState(() {
                                            selectedCategory = val;
                                            if (hasSubmitAttempt) validate();
                                        });
                                    }
                                ),
                                if (categoryError != null) errorText(categoryError!),
                                const SizedBox(height: 16),

                                // Transaction type chips
                                Text(
                                    'Type',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold
                                    )
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                    spacing: 8,
                                    children: TransactionType.values.map((type) {
                                        final isSelected = selectedType == type;
                                        final primary = theme.colorScheme.primary;
                                        return GestureDetector(
                                            onTap: () => setState(() => selectedType = type),
                                            child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                decoration: BoxDecoration(
                                                    color: isSelected 
                                                        ? primary.withOpacity(0.15) 
                                                        : Colors.transparent,
                                                    border: Border.all(
                                                        color: isSelected 
                                                            ? primary 
                                                            : theme.disabledColor,
                                                        width: isSelected 
                                                            ? 2 
                                                            : 1
                                                    ),
                                                    borderRadius: BorderRadius.circular(20)
                                                ),
                                                child: Text(
                                                    type.name,
                                                    style: TextStyle(
                                                        color: isSelected 
                                                            ? primary 
                                                            : theme.textTheme.bodyMedium?.color,
                                                        fontWeight: isSelected 
                                                            ? FontWeight.bold 
                                                            : FontWeight.normal
                                                    )
                                                )
                                            )
                                        );
                                    }).toList(),
                                ),
                                const SizedBox(height: 16),

                                TextField(
                                    controller: noteController,
                                    style: theme.textTheme.bodyLarge,
                                    decoration: const InputDecoration(
                                        labelText: 'Note (optional)',
                                        border: OutlineInputBorder()
                                    ),
                                    maxLines: 2,
                                    textCapitalization: TextCapitalization.sentences
                                ),
                                const SizedBox(height: 24),

                                // Submit
                                SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                        onPressed: isLoading ? null : submit,
                                        child: isLoading
                                            ? const SizedBox(
                                                height: 20, width: 20,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                            : Text(isEdit 
                                                ? 'Save Changes' 
                                                : 'Add Transaction')
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