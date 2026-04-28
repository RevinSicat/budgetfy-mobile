import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/category/category.dart';
import '../../common/utils/color_utility.dart';
import '../../common/widgets/category_form.dart';

class CategoryCard extends ConsumerWidget {
    final Category category;
    const CategoryCard({super.key, required this.category});

    void openEditForm(BuildContext context) {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => CategoryForm(category: category),
        );
    }

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final theme = Theme.of(context);

        return GestureDetector(
            onTap: () => openEditForm(context),
            child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                            spreadRadius: 1,
                        )
                    ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // align children to start
                    children: [
                        Row(
                            children: [
                                Container(
                                    width: 14,
                                    height: 14,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                        color: hexToColor(category.color),
                                        shape: BoxShape.circle,
                                    ),
                                ),
                                Expanded(  // ← wrap in Expanded to prevent overflow
                                    child: Text(
                                        category.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                    ),
                                ),
                            ],
                        ),

                        const SizedBox(height: 10),

                        // Type badge (width = text only)
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: category.type == CategoryType.income
                                    ? Colors.lightGreen.withOpacity(0.2)
                                    : Colors.redAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                                category.type == CategoryType.income ? 'INCOME' : 'EXPENSE',
                                style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: category.type == CategoryType.income
                                    ? Colors.lightGreen
                                    : Colors.redAccent,
                                ),
                            ),
                        ),
                    ],
                )
            ),
        );
    }
}