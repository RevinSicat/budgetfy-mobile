import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/category/category.dart';
import '../../../features/subcategory/subcategory_provider.dart';
import '../../utils/color_utility.dart';
import '../forms/category_form.dart';

class CategoryTile extends ConsumerStatefulWidget {
    final Category category;
    const CategoryTile({super.key, required this.category});

    @override
    ConsumerState<CategoryTile> createState() => CategoryTileState();
}

class CategoryTileState extends ConsumerState<CategoryTile>
    with SingleTickerProviderStateMixin {
    bool isExpanded = false;
    late AnimationController _animController;
    late Animation<double> _expandAnimation;

    @override
    void initState() {
        super.initState();
        _animController = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 250),
        );
        _expandAnimation = CurvedAnimation(
            parent: _animController,
            curve: Curves.easeInOut,
        );
    }

    @override
    void dispose() {
        _animController.dispose();
        super.dispose();
    }

    void toggleExpand() {
        setState(() => isExpanded = !isExpanded);
        if (isExpanded) {
            _animController.forward();
        } else {
            _animController.reverse();
        }
    }

    void openEditForm(BuildContext context) {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16))
            ),
            builder: (_) => CategoryForm(category: widget.category)
        );
    }

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        final category = widget.category;
        final subcategoryCount = ref.watch(
            getSubcategoryCountByCategoryIdProvider(category.id)
        );
        final isIncome = category.type == CategoryType.income;

        return Column(
            children: [
                GestureDetector(
                    onTap: toggleExpand,
                    child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(12),
                            border: theme.brightness == Brightness.dark
                                ? Border.all(color: Colors.white10)
                                : Border.all(color: Colors.grey.shade200)
                        ),
                        child: Row(
                            children: [
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text(
                                                category.name,
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis
                                            ),
                                            const SizedBox(height: 4),
                                            subcategoryCount.when(
                                                loading: () => const SizedBox(
                                                    height: 10, width: 10, 
                                                    child: CircularProgressIndicator(strokeWidth: 1)
                                                ),
                                                error: (_, __) => const SizedBox.shrink(),
                                                data: (count) => Text(
                                                    '$count subcategor${count == 1 ? 'y' : 'ies'}',
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                        fontSize: 12,
                                                        color: theme.colorScheme.primary.withOpacity(0.8),
                                                    )
                                                )
                                            )
                                        ]
                                    )
                                ),
                                Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: isIncome
                                                    ? Colors.green.withOpacity(0.15)
                                                    : Colors.red.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: isIncome 
                                                        ? Colors.green.withOpacity(0.5)
                                                        : Colors.red.withOpacity(0.5),
                                                    width: 1,
                                                ),
                                            ),
                                            child: Text(
                                                isIncome ? 'INCOME' : 'EXPENSE',
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: isIncome ? Colors.green : Colors.red
                                                )
                                            )
                                        ),
                                        const SizedBox(width: 12),
                                        GestureDetector(
                                            onTap: () => openEditForm(context),
                                            child: Icon(
                                                Icons.edit_outlined, // Outlined looks cleaner
                                                size: 18,
                                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)
                                            )
                                        ),
                                        const SizedBox(width: 8),
                                        AnimatedRotation(
                                            turns: isExpanded ? 0.5 : 0,
                                            duration: const Duration(milliseconds: 250),
                                            child: Icon(
                                                Icons.expand_more,
                                                size: 22,
                                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4)
                                            )
                                        )
                                    ]
                                )
                            ]
                        )
                    )
                ),
                SizeTransition(
                    sizeFactor: _expandAnimation,
                    child: _SubcategoryAccordion(category: category)
                )
            ]
        );
    }
}

class _SubcategoryAccordion extends ConsumerWidget {
    final Category category;
    const _SubcategoryAccordion({required this.category});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final theme = Theme.of(context);
        final subcategories = ref.watch(subcategoryByCategoryProvider(category.id));

        return Container(
            margin: const EdgeInsets.only(left: 24, right: 8, bottom: 4),
            decoration: BoxDecoration(
                border: Border(
                    left: BorderSide(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        width: 2
                    )
                )
            ),
            child: subcategories.when(
                loading: () => const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator())
                ),
                error: (e, _) => Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('Error: $e')
                ),
                data: (subs) {
                    if (subs.isEmpty) {
                        return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8
                            ),
                            child: Text(
                                'No subcategories yet.',
                                style: theme.textTheme.bodyMedium
                            )
                        );
                    }

                    return Column(
                        children: subs.map((sub) => Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10,
                            ),
                            decoration: BoxDecoration(
                                color: theme.cardTheme.color,
                                borderRadius: BorderRadius.circular(8),
                                border: theme.brightness == Brightness.dark
                                    ? Border.all(color: Colors.white10)
                                    : null,
                                boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(
                                            theme.brightness == Brightness.light ? 0.06 : 0.2,
                                        ),
                                        offset: const Offset(1, 1),
                                        blurRadius: 2,
                                    ),
                                ],
                            ),
                            child: Row(
                                children: [
                                    Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                            color: hexToColor(category.color),
                                            shape: BoxShape.circle,
                                        ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: Text(
                                            sub.name,
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                        ),
                                    ),
                                ],
                            ),
                        )).toList(),
                    );
                },
            ),
        );
    }
}