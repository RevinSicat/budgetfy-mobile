import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/local/local_database.dart';
import '../../core/sync/sync_service.dart';
import '../transaction/transaction_service.dart';
import 'category.dart';

class CategoryService {
    final LocalDatabase _db;
    final SyncService _sync;

    CategoryService(this._db) : _sync = SyncService(_db);

    /// [GET]: Retrieve all non-deleted Categories
    Future<List<Category>> findAll() async {
        final rows = await _db.categoryDao.getAllCategories();
        return rows.map((row) => Category(
            id: row.id,
            name: row.name,
            color: row.color,
            type: CategoryType.values.firstWhere(
                (e) => e.name == row.type,
                orElse: () => CategoryType.expense
            )
        )).toList();
    }

    /// [POST]: Create Category
    Future<void> save(Category category) async {
        final id = category.id.isEmpty ? const Uuid().v4() : category.id;

        await _db.categoryDao.saveCategory(CategoriesCompanion(
            id: Value(id),
            name: Value(category.name),
            color: Value(category.color),
            type: Value(category.type.name),
            updatedAt: Value(DateTime.now().toUtc())
        ));

        await _sync.pushRecordNow();
    }

    /// [PUT]: Update Category — inverts transaction amounts when type changes
    Future<void> update(Category category) async {
        final prev = await _db.categoryDao.getCategoryById(category.id);
        final typeChanged = prev != null && prev.type != category.type.name;

        await _db.categoryDao.updateCategory(CategoriesCompanion(
            id: Value(category.id),
            name: Value(category.name),
            color: Value(category.color),
            type: Value(category.type.name),
            updatedAt: Value(DateTime.now().toUtc()),
            pendingSync: const Value(true)
        ));

        if (typeChanged) {
            await TransactionService(_db).updateAmountByCategory(category.id);
        }

        await _sync.pushRecordNow();
    }

    /// [DELETE]: Soft-delete Category by {id}
    Future<void> deleteById(String id) async {
        await _db.categoryDao.softDeleteCategoryById(id);
        await _sync.pushRecordNow();
    }
}