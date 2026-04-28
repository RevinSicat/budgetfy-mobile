import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/category/category.dart';
import '../../features/category/category_provider.dart';
import '../utils/color_utility.dart';

class CategoryForm extends ConsumerStatefulWidget {
    final Category? category;
    const CategoryForm({
        super.key,
        this.category
    });

    @override
    ConsumerState<CategoryForm> createState() => CategoryFormState();
}

class CategoryFormState extends ConsumerState<CategoryForm> {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    CategoryType selectedType = CategoryType.expense;
    String selectedColor = colorList[0];
    bool isLoading = false;

    @override
    void initState() {
        super.initState();
        if (widget.category != null) {
            nameController.text = widget.category!.name;
            selectedColor = widget.category!.color;
            selectedType = widget.category!.type;
        }
    }

    @override
    void dispose() {
        nameController.dispose();
        super.dispose();
    }

    Future<void> submit() async {
        if (!formKey.currentState!.validate()) {
            return;
        }

        setState(() {
            isLoading = true;
        });

        try {
            final service = ref.read(categoryServiceProvider);

            if (widget.category == null) {
                await service.save(
                    Category(
                        id: '', 
                        name: nameController.text.trim(), 
                        color: selectedColor, 
                        type: selectedType
                    )
                );
            } else {
                await service.update(
                    Category(
                        id: widget.category!.id, 
                        name: nameController.text.trim(), 
                        color: selectedColor, 
                        type: selectedType
                    )
                );
            }

            ref.invalidate(getAllCategoryListProvider);
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

    Future<void> deleteCategory() async {
        final confirm = await showDialog(
            context: context, 
            builder: (ctx) => AlertDialog(
                title: const Text('Delete Category'),
                content: Text('Are you sure you want to delete "${widget.category!.name}"? This cannot be undone.'),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false), 
                        child: const Text('Cancel'),
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

        setState(
            () => isLoading = true
        );
        try {
            await ref.read(categoryServiceProvider).deleteById(widget.category!.id);
            ref.invalidate(getAllCategoryListProvider);
            if (mounted) Navigator.pop(context);
        } catch (e) {
            setState(
                () => isLoading = false
            );
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error delete category: $e'))
                );
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        final isEdit = widget.category != null;

        return Padding(
            padding: EdgeInsets.only(
                left: 16, right: 16, top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Form(
                key: formKey,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Text(isEdit 
                                        ? 'Edit Category' 
                                        : 'Add Category',
                                    style: theme.textTheme.titleLarge
                                ),
                                if (isEdit)
                                IconButton(
                                    onPressed: isLoading ? null : deleteCategory,
                                    icon: const Icon(
                                        Icons.delete, color: 
                                        Colors.red
                                    )
                                )
                            ]
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                                labelText: 'Category Name',
                                border: OutlineInputBorder(),
                                errorStyle: TextStyle(fontWeight: FontWeight.w500)
                            ),
                            textCapitalization: TextCapitalization.words,
                            maxLength: 64,
                            validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                return 'Please enter a category name';
                                }
                                return null;
                            }
                        ),

                        const SizedBox(height: 16),
                        
                        Text(
                            'Type',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold
                            )
                        ),
                        const SizedBox(height: 8),
                        Row(
                            children: [
                                TypeChip(
                                    label: 'Expense',
                                    isSelected: selectedType == CategoryType.expense,
                                    color: Colors.red,
                                    onTap: () => setState(
                                        () => selectedType = CategoryType.expense
                                    )
                                ),
                                const SizedBox(width: 8),
                                TypeChip(
                                    label: 'Income',
                                    isSelected: selectedType == CategoryType.income,
                                    color: Colors.green,
                                    onTap: () => setState(
                                        () => selectedType = CategoryType.income
                                    )
                                )
                            ]
                        ),
                        const SizedBox(height: 16),
                        
                        Text(
                            'Color',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold
                            )
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                            spacing: 8,
                            runSpacing: 8,
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
                                            ? Border.all(
                                                color: theme.brightness == Brightness.light 
                                                    ? Colors.black 
                                                    : Colors.white,
                                                width: 3
                                            )
                                            : null
                                        )
                                    )
                                );
                            }).toList()
                        ),

                        const SizedBox(height: 24),
                        
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: isLoading ? null : submit,
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2)
                                    )
                                    : Text(isEdit ? 'Save Changes' : 'Add Category')
                            )
                        )
                    ]
                )
            )
        );
    }
}

    class TypeChip extends StatelessWidget {
    final String label;
    final bool isSelected;
    final Color color;
    final VoidCallback onTap;

    const TypeChip({
        super.key,
        required this.label,
        required this.isSelected,
        required this.color,
        required this.onTap,
    });

    @override
    Widget build(BuildContext context) {
        return GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            border: Border.all(
                color: isSelected ? color : Colors.grey.shade400,
                width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
            label,
            style: TextStyle(
                color: isSelected ? color : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            ),
        ),
        );
    }
}