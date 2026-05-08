import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/local/local_database_provider.dart';
import 'subcategory.dart';
import 'subcategory_service.dart';

final subcategoryServiceProvider = Provider<SubcategoryService>((ref) {
    final db = ref.watch(localDatabaseProvider);
    return SubcategoryService(db);
});

final subcategoryByCategoryProvider = FutureProvider.family<List<Subcategory>, String>(
    (ref, categoryId) async {
        final service = ref.read(subcategoryServiceProvider);
        return service.getByCategoryId(categoryId);
    },
);

final getSubcategoryCountByCategoryIdProvider = FutureProvider.family<int, String>(
    (ref, categoryId) async {
        final service = ref.read(subcategoryServiceProvider);
        return service.getSubcategoryCountByCategoryId(categoryId);
    },
);