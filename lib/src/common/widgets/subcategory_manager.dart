import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/subcategory/subcategory.dart';
import '../../features/subcategory/subcategory_provider.dart';

class SubcategoryManager extends ConsumerStatefulWidget {
    final String categoryId;
    const SubcategoryManager({super.key, required this.categoryId});

    @override
    ConsumerState<SubcategoryManager> createState() => SubcategoryManagerState();
}

class SubcategoryManagerState extends ConsumerState<SubcategoryManager> {
    final nameController = TextEditingController();
    bool isAdding = false;

    @override
    void dispose() {
        nameController.dispose();
        super.dispose();
    }

    Future<void> addSubcategory() async {
        if (nameController.text.trim().isEmpty) return;
        setState(() => isAdding = true);
        try {
            final service = ref.read(subcategoryServiceProvider);
            await service.save(Subcategory(
                id: '',
                categoryId: widget.categoryId,
                name: nameController.text.trim(),
            ));
            nameController.clear();
            ref.invalidate(subcategoryByCategoryProvider(widget.categoryId));
        } catch (e) {
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                );
            }
        } finally {
            setState(() => isAdding = false);
        }
    }

    Future<void> deleteSubcategory(String id) async {
        final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
                title: const Text('Delete Subcategory'),
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

        try {
            final service = ref.read(subcategoryServiceProvider);
            await service.deleteById(id);
            ref.invalidate(subcategoryByCategoryProvider(widget.categoryId));
        } catch (e) {
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                );
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        final subcategories = ref.watch(subcategoryByCategoryProvider(widget.categoryId));

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                // Subcategory list
                subcategories.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                    data: (subs) {
                        if (subs.isEmpty) {
                            return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                    'No subcategories yet.',
                                    style: theme.textTheme.bodyMedium
                                )
                            );
                        }
                        return Column(
                            children: subs.map((sub) => _SubcategoryTile(
                                subcategory: sub,
                                onDelete: () => deleteSubcategory(sub.id),
                            )).toList()
                        );
                    }
                ),
                const SizedBox(height: 12),
                Row(
                    children: [
                        Expanded(
                            child: TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                    hintText: 'New subcategory name',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10
                                    )
                                ),
                                textCapitalization: TextCapitalization.words,
                                onSubmitted: (_) => addSubcategory()
                            )
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                            onPressed: isAdding ? null : addSubcategory,
                            child: isAdding
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2)
                                )
                                : const Text('Add')
                        )
                    ]
                )
            ]
        );
    }
}

class _SubcategoryTile extends StatelessWidget {
    final Subcategory subcategory;
    final VoidCallback onDelete;

    const _SubcategoryTile({
        required this.subcategory,
        required this.onDelete
    });

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);

        return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(8),
                border: theme.brightness == Brightness.dark
                    ? Border.all(color: Colors.white10)
                    : null,
                boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(
                            theme.brightness == Brightness.light ? 0.1 : 0.3
                        ),
                        offset: const Offset(2, 2),
                        blurRadius: 2,
                        spreadRadius: 1
                    )
                ]
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.6),
                            shape: BoxShape.circle
                        )
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            subcategory.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis
                        )
                    ),
                    GestureDetector(
                        onTap: onDelete,
                        child: Icon(
                            Icons.delete,
                            size: 18,
                            color: Colors.red.withOpacity(0.8)
                        )
                    )
                ]
            )
        );
    }
}