import 'package:drift/drift.dart';
import '../local_database.dart';

part 'subcategory_dao.g.dart';

@DriftAccessor(tables: [Subcategories])
class SubcategoryDao extends DatabaseAccessor<LocalDatabase> with _$SubcategoryDaoMixin {
    SubcategoryDao(super.db);

    /// [GET]: Retrieve all non-deleted Subcategories by {categoryId} ordered by {name}
    Future<List<SubcategoryData>> getSubcategoriesByCategoryId(String categoryId) {
        return (
            select(subcategories)
                ..where((t) =>
                    t.categoryId.equals(categoryId) &
                    t.isDeleted.equals(false)
                )
                ..orderBy([(t) => OrderingTerm.asc(t.name)])
        ).get();
    }

    /// [GET]: Retrieve Subcategory Count by {categoryId}
    Future<int> getSubcategoriesCountByCategoryId(String categoryId) async {
        final count = countAll(
            filter: subcategories.categoryId.equals(categoryId)
                & subcategories.isDeleted.equals(false),
        );
        final query = selectOnly(subcategories)..addColumns([count]);
        final result = await query.getSingle();
        return result.read(count) ?? 0;
    }

    /// [GET]: Retrieve all Subcategories pending sync to Supabase
    Future<List<SubcategoryData>> getAllPendingSubcategories() {
        return (
            select(subcategories)
                ..where((t) => t.pendingSync.equals(true))
        ).get();
    }

    /// [POST]: Create Subcategory
    Future<void> saveSubcategory(SubcategoriesCompanion entry) {
        return into(subcategories).insertOnConflictUpdate(entry);
    }

    /// [PUT]: Update Subcategory
    Future<void> updateSubcategory(SubcategoriesCompanion entry) {
        return (
            update(subcategories)
                ..where((t) => t.id.equals(entry.id.value))
        ).write(entry);
    }

    /// [PUT]: Mark Subcategory as synced by {id}
    Future<void> updateSubcategoryAsSyncedById(String id) {
        return (
            update(subcategories)
                ..where((t) => t.id.equals(id))
        ).write(const SubcategoriesCompanion(
            pendingSync: Value(false),
        ));
    }

    /// [DELETE]: Mark Subcategory as deleted by {id}
    Future<void> softDeleteSubcategoryById(String id) {
        return (
            update(subcategories)
                ..where((t) => t.id.equals(id))
        ).write(SubcategoriesCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(DateTime.now()),
            pendingSync: const Value(true),
        ));
    }
}