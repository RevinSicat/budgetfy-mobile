import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'subcategory.dart';
import 'subcategory_service.dart';

final subcategoryServiceProvider = Provider<SubcategoryService>((ref) {
    return SubcategoryService();
});

final subcategoryByCategoryProvider = FutureProvider.family<List<Subcategory>, String>((ref, categoryId) async {
    final service = ref.read(subcategoryServiceProvider);
    return service.getByCategoryId(categoryId);
});

final getSubcategoryCountByCategoryIdProvider = FutureProvider.family<int, String>((ref, categoryId) async {
    final service = ref.read(subcategoryServiceProvider);
    return service.getSubcategoryCountByCategoryId(categoryId);
});