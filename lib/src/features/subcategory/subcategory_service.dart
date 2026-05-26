import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/local/local_database.dart';
import '../../core/sync/sync_service.dart';
import 'subcategory.dart';

class SubcategoryService {
    final LocalDatabase _db;
    final SyncService _syncService;

    SubcategoryService(this._db) : _syncService = SyncService(_db);

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

        final companion = SubcategoriesCompanion(
            id: Value(subcategoryId),
            categoryId: Value(subcategory.categoryId),
            name: Value(subcategory.name),
            updatedAt: Value(DateTime.now()),
            pendingSync: const Value(true)
        );

        await _db.subcategoryDao.saveSubcategory(companion);

        await _syncService.writeToOutbox(
            tableName: 'subcategories', 
            recordId: subcategoryId, 
            operation: 'create', 
            payload: subcategory.toJson()
                ..['id'] = subcategoryId
                ..['updated_at'] = DateTime.now().toIso8601String(),
        );
    }

    /// [PUT]: Update Subcategory
    Future<void> update(Subcategory subcategory) async {
        final updatedAt = DateTime.now();

        await _db.subcategoryDao.updateSubcategory(SubcategoriesCompanion(
            id: Value(subcategory.id),
            categoryId: Value(subcategory.categoryId),
            name: Value(subcategory.name),
            updatedAt: Value(updatedAt),
            pendingSync: const Value(true)
        ));

        await _syncService.writeToOutbox(
            tableName: 'subcategories', 
            recordId: subcategory.id, 
            operation: 'update', 
            payload: subcategory.toJson()
                ..['updated_at'] = updatedAt.toIso8601String(),
        );
    }

    /// [DELETE]: Soft delete Subcategory by {id}
    Future<void> deleteById(String id) async {
        await _db.subcategoryDao.softDeleteSubcategoryById(id);

        await _syncService.writeToOutbox(
            tableName: 'subcategories',
            recordId:  id,
            operation: 'delete',
            payload:   {
                'id': id, 
                'updated_at': DateTime.now().toIso8601String()
            }
        );
    }
}