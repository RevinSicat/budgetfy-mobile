import 'package:drift/drift.dart';
import '../local_database.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<LocalDatabase> with _$CategoryDaoMixin {
    CategoryDao(super.db);

    /// [GET]: Retrieve all non-deleted Categories ordered by {name}
    Future<List<CategoryData>> getAllCategories() {
        return (
            select(categories)
                ..where((t) => t.isDeleted.equals(false))
                ..orderBy([(t) => OrderingTerm.asc(t.name)])
        ).get();
    }

    /// [GET]: Retrieve Category by {id}
    Future<CategoryData?> getCategoryById(String id) {
        return (
            select(categories)
                ..where((t) => t.id.equals(id))
        ).getSingleOrNull();
    }

    /// [GET]: Retrieve all Categories pending sync to Supabase
    Future<List<CategoryData>> getAllPendingCategories() {
        return (
            select(categories)
                ..where((t) => t.pendingSync.equals(true))
        ).get();
    }

    /// [POST]: Create Category
    Future<void> saveCategory(CategoriesCompanion entry) {
        return into(categories).insertOnConflictUpdate(entry);
    }

    /// [PUT]: Update Category
    Future<void> updateCategory(CategoriesCompanion entry) {
        return (
            update(categories)
                ..where((t) => t.id.equals(entry.id.value))
        ).write(entry);
    }

    /// [PUT]: Mark Category as synced by {id}
    Future<void> updateCategoryAsSyncedById(String id) {
        return (
            update(categories)
                ..where((t) => t.id.equals(id))
        ).write(const CategoriesCompanion(
            pendingSync: Value(false),
        ));
    }

    /// [DELETE]: Mark Category as deleted by {id}
    Future<void> softDeleteCategoryById(String id) {
        return (
            update(categories)
                ..where((t) => t.id.equals(id))
        ).write(CategoriesCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(DateTime.now()),
            pendingSync: const Value(true),
        ));
    }
}