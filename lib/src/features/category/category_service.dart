import '../../core/connection/supabase_config.dart';
import '../category/category.dart';

class CategoryService {
    final _sbdb = SupabaseConfig.client;

    /// [GET]: Retreives Category List
    Future<List<Category>> getCategoryList() async {
        try {
            final response = await _sbdb.from('categories')
                .select()
                .order('name', ascending: true);

            return (response as List)
                .map((json) => Category.fromJson(json))
                .toList();
        } catch (e) {
            print('[Error fetching category list]: $e');
            rethrow;
        }
    }

    /// [POST]: Create Category
    Future<void> createCategory(Category category) async {
        try {
            await _sbdb.from('categories')
                .insert(category.toJson());
        } catch (e) {
            print('[Error creating category]: $e');
            rethrow;
        }
    }

    /// [PUT]: Update Category
    Future<void> updateCategory(Category category) async {
        try {
            await _sbdb.from('categories')
                .update(category.toJson())
                .eq('id', category.id);
        } catch (e) {
            print('[Error updating category]: $e');
            rethrow;
        }
    }

    /// [DELETE]: Delete Category
    Future<void> deleteCategory(String id) async {
        try {
            await _sbdb.from('categories')
                .delete()
                .eq('id', id);
        } catch (e) {
            print('[Error deleting category]: $e');
            rethrow;
        }
    }
}