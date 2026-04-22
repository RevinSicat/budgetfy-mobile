import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/category/category_provider.dart';
import '../../common/utils/color_utility.dart';
import '../../common/widgets/triangle_indicator.dart';

class CategoryScreen extends ConsumerWidget {
    const CategoryScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final categoryList = ref.watch(getAllCategoryListProvider);
        return Scaffold(
            appBar: AppBar(title: const Text('Categories')),
            body: categoryList.when(
                data: (categories) => ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                        final category = categories[index];
                        return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: hexToColor(category.color),
                                    width: 2
                                ),
                                borderRadius: BorderRadius.circular(8)
                            ),
                            child: ListTile(
                                title: Text(category.name),
                                trailing: TriangleIndicator(isIncome: category.type.name == 'income')
                            )
                        );
                    }
                ),
                loading: () => const Center(
                    child: CircularProgressIndicator()
                ),
                error: (e, _) => Center(
                    child: Text('Error encountered: $e')
                )
            ),
        );
    }
}