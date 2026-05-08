import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/local/local_database_provider.dart';
import 'category.dart';
import 'category_service.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
    final db = ref.watch(localDatabaseProvider);
    return CategoryService(db);
});

final getAllCategoryListProvider = FutureProvider<List<Category>>((ref) async {
    final service = ref.read(categoryServiceProvider);
    return service.getAllList();
});