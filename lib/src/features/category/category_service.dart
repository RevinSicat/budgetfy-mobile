import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/local/local_database.dart'; 
import '../../core/sync/sync_service.dart';
import '../transaction/transaction_service.dart';
import 'category.dart';

class CategoryService {
    final LocalDatabase _db;
    final SyncService _syncService;
    late final TransactionService _transactionService;

    CategoryService(this._db) : _syncService = SyncService(_db) {
        _transactionService = TransactionService(_db);
    }

    /// [GET]: Retrieves Category List
    Future<List<Category>> getAllList() async {
        final rows = await _db.categoryDao.getAllCategories();
        return rows.map((row) => Category(
            id: row.id,
            name: row.name,
            color: row.color,
            type: CategoryType.values.firstWhere(
                (e) => e.name == row.type,
                orElse: () => CategoryType.expense,
            ),
        )).toList();
    }

    /// [POST]: Create Category
    Future<void> save(Category category) async {
        final categoryId = category.id.isEmpty
            ? const Uuid().v4()
            : category.id;

        final companion = CategoriesCompanion(
            id: Value(categoryId),
            name: Value(category.name),
            color: Value(category.color),
            type: Value(category.type.name),
            updatedAt: Value(DateTime.now()),
            pendingSync: const Value(true)
        );

        await _db.categoryDao.saveCategory(companion);

        await _syncService.writeToOutbox(
            tableName: 'categories', 
            recordId: categoryId, 
            operation: 'create', 
            payload: category.toJson()
                ..['id'] = categoryId
                ..['updated_at'] = DateTime.now().toIso8601String()
        );
    }

    /// [PUT]: Update Category
        Future<void> update(Category category) async {
        final updatedAt = DateTime.now();
        final prev = await _db.categoryDao.getCategoryById(category.id);
        final isTypeChanged = prev != null && prev.type != category.type.name;

        await _db.categoryDao.updateCategory(CategoriesCompanion(
            id:          Value(category.id),
            name:        Value(category.name),
            color:       Value(category.color),
            type:        Value(category.type.name),
            updatedAt:   Value(updatedAt),
            pendingSync: const Value(true),
        ));

        // Uses the shared instance — outbox writes included
        if (isTypeChanged) {
            await _transactionService.updateAmountByCategory(category.id);
        }

        await _syncService.writeToOutbox(
            tableName: 'categories',
            recordId:  category.id,
            operation: 'update',
            payload:   category.toJson()
                ..['updated_at'] = updatedAt.toIso8601String(),
        );
    }

    /// [DELETE]: Soft delete Category by {id}
    Future<void> deleteById(String id) async {
        await _db.categoryDao.softDeleteCategoryById(id);

        await _syncService.writeToOutbox(
            tableName: 'categories', 
            recordId: id, 
            operation: 'delete', 
            payload: {
                'id': id,
                'updated_at': DateTime.now().toIso8601String() 
            }
        );
    }
}