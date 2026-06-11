import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/local/local_database.dart';
import '../../core/sync/sync_service.dart';
import 'subcategory.dart';

class SubcategoryService {
    final LocalDatabase _db;
    final SyncService _sync;

    SubcategoryService(this._db) : _sync = SyncService(_db);

    /// [GET]: Retrieve all non-deleted Subcategories by {categoryId}
    Future<List<Subcategory>> findByCategoryId(String categoryId) async {
        final rows = await _db.subcategoryDao.getSubcategoriesByCategoryId(categoryId);
        return rows.map((row) => Subcategory(
            id: row.id,
            categoryId: row.categoryId,
            name: row.name
        )).toList();
    }

    /// [GET]: Retrieve Subcategory count by {categoryId}
    Future<int> countByCategoryId(String categoryId) {
        return _db.subcategoryDao.getSubcategoriesCountByCategoryId(categoryId);
    }

    /// [POST]: Create Subcategory
    Future<void> save(Subcategory subcategory) async {
        final id = subcategory.id.isEmpty ? const Uuid().v4() : subcategory.id;

        await _db.subcategoryDao.saveSubcategory(SubcategoriesCompanion(
            id: Value(id),
            categoryId: Value(subcategory.categoryId),
            name: Value(subcategory.name),
            updatedAt: Value(DateTime.now().toUtc())
        ));

        await _sync.pushRecordNow();
    }

    /// [PUT]: Update Subcategory
    Future<void> update(Subcategory subcategory) async {
        await _db.subcategoryDao.updateSubcategory(SubcategoriesCompanion(
            id: Value(subcategory.id),
            categoryId: Value(subcategory.categoryId),
            name: Value(subcategory.name),
            updatedAt: Value(DateTime.now().toUtc()),
            pendingSync: const Value(true)
        ));

        await _sync.pushRecordNow();
    }

    /// [DELETE]: Soft-delete Subcategory by {id}
    Future<void> deleteById(String id) async {
        await _db.subcategoryDao.softDeleteSubcategoryById(id);
        await _sync.pushRecordNow();
    }
}