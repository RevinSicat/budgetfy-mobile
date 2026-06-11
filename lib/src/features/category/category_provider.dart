import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/local/local_database_provider.dart';
import 'category.dart';
import 'category_service.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
    return CategoryService(ref.watch(localDatabaseProvider));
});

final getAllCategoryListProvider = FutureProvider<List<Category>>((ref) async {
    return ref.read(categoryServiceProvider).findAll();
});