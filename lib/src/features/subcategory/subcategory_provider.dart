import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/local/local_database_provider.dart';
import 'subcategory.dart';
import 'subcategory_service.dart';

final subcategoryServiceProvider = Provider<SubcategoryService>((ref) {
    return SubcategoryService(ref.watch(localDatabaseProvider));
});

final subcategoryByCategoryProvider = FutureProvider.family<List<Subcategory>, String>((ref, categoryId) async {
    return ref.read(subcategoryServiceProvider).findByCategoryId(categoryId);
});

final getSubcategoryCountByCategoryIdProvider = FutureProvider.family<int, String>((ref, categoryId) async {
    return ref.read(subcategoryServiceProvider).countByCategoryId(categoryId);
});