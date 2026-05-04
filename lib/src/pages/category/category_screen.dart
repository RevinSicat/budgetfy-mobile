import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/category/category_provider.dart';
import '../../common/widgets/forms/category_form.dart';
import '../../common/widgets/tiles/category_tiles.dart'; 

class CategoryScreen extends ConsumerWidget {
    const CategoryScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final theme = Theme.of(context);
        final categoryList = ref.watch(getAllCategoryListProvider);

        return Scaffold(
            /// [Category Header]: ================================================================
            appBar: AppBar(
                title: Text(
                    'Categories',
                    style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold
                    )
                )
            ),
            /// [Category Tiles List]: ============================================================
            body: categoryList.when(
                data: (categories) {
                    if (categories.isEmpty) {
                        return const Center(child: Text('No categories found.'));
                    }

                    return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                            final category = categories[index];
                            return CategoryTile(category: category);
                        },
                    );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error encountered: $e')),
            ),
            /// [Add Category Button]: ============================================================
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (_) => const CategoryForm(),
                    );
                },
                child: const Icon(Icons.add),
            ),
        );
    }
}