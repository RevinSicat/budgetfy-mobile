import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'category.dart';
import 'category_service.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
    return CategoryService();
});

final getAllListProvider = FutureProvider<List<Category>>((ref) async {
    final service = ref.read(categoryServiceProvider);
    return service.getAllList();
});