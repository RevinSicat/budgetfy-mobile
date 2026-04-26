import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/category/category_provider.dart';
import '../../common/widgets/category_form.dart';
import '../../common/widgets/category_card.dart';

class CategoryScreen extends ConsumerWidget {
    const CategoryScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final categoryList = ref.watch(getAllCategoryListProvider);

        return Scaffold(
            appBar: AppBar(
                title: const Text(
                    'Categories',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
            ),
            backgroundColor: const Color(0xFFF9F9F9),
            body: categoryList.when(
                data: (categories) => SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                        spacing: 12,      // horizontal spacing between cards
                        runSpacing: 12,   // vertical spacing between rows
                        children: categories.map((c) {
                        return SizedBox(
                            width: (MediaQuery.of(context).size.width - 50 - (12 * 2)) / 3,
                            // screen width minus total horizontal padding and spacing, divided by 3
                            child: CategoryCard(category: c),
                        );
                        }).toList(),
                    ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error encountered: $e')),
            ),
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