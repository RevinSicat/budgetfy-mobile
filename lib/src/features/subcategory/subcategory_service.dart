import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/local/local_database.dart';
import 'subcategory.dart';

class SubcategoryService {
    final LocalDatabase _db;

    SubcategoryService(this._db);

    /// [GET]: Retreive Subcategories by {categoryId}
    Future<List<Subcategory>> getByCategoryId(String categoryId) async {
        final rows = await _db.subcategoryDao.getSubcategoriesByCategoryId(categoryId);
        return rows.map((row) => Subcategory(
            id: row.id,
            categoryId: row.categoryId,
            name: row.name,
        )).toList();
    }

    /// [GET]: Retreive Subcategory Count by {categoryId}
    Future<int> getSubcategoryCountByCategoryId(String categoryId) {
        return _db.subcategoryDao.getSubcategoriesCountByCategoryId(categoryId);
    }

    /// [POST]: Create Subcategory
    Future<void> save(Subcategory subcategory) async {
        final subcategoryId = subcategory.id.isEmpty
        ? const Uuid().v4()
        : subcategory.id;

        await _db.subcategoryDao.saveSubcategory(SubcategoriesCompanion(
            id: Value(subcategoryId),
            categoryId: Value(subcategory.categoryId),
            name: Value(subcategory.name),
            updatedAt: Value(DateTime.now()),
        ));
    }

    /// [PUT]: Update Subcategory
    Future<void> update(Subcategory subcategory) async {
        await _db.subcategoryDao.updateSubcategory(SubcategoriesCompanion(
            id: Value(subcategory.id),
            categoryId: Value(subcategory.categoryId),
            name: Value(subcategory.name),
            updatedAt: Value(DateTime.now()),
        ));
    }

    /// [DELETE]: Soft delete Subcategory by {id}
    Future<void> deleteById(String id) async {
        await _db.subcategoryDao.softDeleteSubcategoryById(id);
    }
}