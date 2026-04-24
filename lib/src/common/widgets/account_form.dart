import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../src/features/account/account.dart';
import '../../../src/features/account/account_service.dart';
import '../../../src/features/account/account_provider.dart';
import '../utils/color_utility.dart';

class AccountForm extends ConsumerStatefulWidget {
    final Account? account;
    const AccountForm({
        super.key,
        this.account
    });

    @override
    ConsumerState<AccountForm> createState() => AccountFormState();
}

class AccountFormState extends ConsumerState<AccountForm> {
    final nameController = TextEditingController();
    String selectedColor = colorList[0];
    bool isLoading = false;
    
    @override
    void initState() {
        super.initState();
        if (widget.account != null) {
            nameController.text = widget.account!.name;
            selectedColor = widget.account!.color;
        }
    }

    @override
    void dispose() {
        nameController.dispose();
        super.dispose();
    }

    Future<void> submit() async {
        if (nameController.text.trim().isEmpty) {
            return;
        }

        setState(() {
            isLoading = true;
        });

        try {
            final service = ref.read(accountServiceProvider);
            final now = DateTime.now();

            if (widget.account == null) {
                await service.save(
                    Account(
                        id: '', 
                        name: nameController.text.trim(), 
                        color: selectedColor, 
                        createdAt: now, 
                        updatedAt: now
                    )
                );
            } else {
                await service.update(
                    Account(
                        id: widget.account!.id, 
                        name: nameController.text.trim(), 
                        color: selectedColor, 
                        createdAt: widget.account!.createdAt, 
                        updatedAt: now
                    )
                );
            }

            ref.invalidate(getAllAccountListProvider);
            if (mounted) {
                Navigator.pop(context);
            }
        } catch (e) {
            setState(() {
                isLoading = false;
                if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'))
                    );
                }
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        final isEdit = widget.account != null;

        return Padding(
            // Pushes form up when keyboard appears
            padding: EdgeInsets.only(
                left: 16, right: 16, top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                        isEdit ? 'Edit Account' : 'Add Account',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                        ),
                    ),
                    const SizedBox(height: 16),

                    // Name field
                    TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                            labelText: 'Account Name',
                            border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),

                    // Color picker
                    const Text('Color', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Wrap(
                        spacing: 8,
                        children: colorList.map((color) {
                            final isSelected = color == selectedColor;
                            return GestureDetector(
                                onTap: () => setState(() => selectedColor = color),
                                child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                        color: hexToColor(color),
                                        shape: BoxShape.circle,
                                        border: isSelected
                                            ? Border.all(color: Colors.black, width: 3)
                                            : null,
                                    ),
                                ),
                            );
                        }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: isLoading ? null : submit,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20, width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                )
                                : Text(isEdit ? 'Save Changes' : 'Add Account'),
                        ),
                    ),
                ],
            ),
        );
    }
}