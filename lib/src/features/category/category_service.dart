import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/local/local_database.dart'; 
import '../transaction/transaction_service.dart';
import 'category.dart';

class CategoryService {
    final LocalDatabase _db;

    CategoryService(this._db);

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

        await _db.categoryDao.saveCategory(CategoriesCompanion(
            id: Value(categoryId),
            name: Value(category.name),
            color: Value(category.color),
            type: Value(category.type.name),
            updatedAt: Value(DateTime.now()),
        ));
    }

    /// [PUT]: Update Category
    Future<void> update(Category category) async {
        final prev = await _db.categoryDao.getCategoryById(category.id);
        final isTypeChanged = prev != null && prev.type != category.type.name;

        await _db.categoryDao.updateCategory(CategoriesCompanion(
            id: Value(category.id),
            name: Value(category.name),
            color: Value(category.color),
            type: Value(category.type.name),
            updatedAt: Value(DateTime.now()),
        ));

        if (isTypeChanged) {
            await TransactionService(_db).updateAmountByCategory(category.id);
        }
    }

    /// [DELETE]: Soft delete Category by {id}
    Future<void> deleteById(String id) async {
        await _db.categoryDao.softDeleteCategoryById(id);
    }
}