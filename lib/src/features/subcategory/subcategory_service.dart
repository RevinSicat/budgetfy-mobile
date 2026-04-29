import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/connection/supabase_config.dart';
import 'subcategory.dart';

class SubcategoryService {
    final _sbdb = SupabaseConfig.client;

    /// [GET]: Retreive Subcategories by category id
    Future<List<Subcategory>> getByCategoryId(String categoryId) async {
        try {
            final response = await _sbdb
                .from('subcategories')
                .select()
                .eq('category_id', categoryId)                         
                .order('name', ascending: true);
            return (response as List)
                .map((json) => Subcategory.fromJson(json))
                .toList();
        } catch (e) {
            print('[Error fetching subcategories]: $e');
            rethrow;
        }
    }

    /// [GET]: Retreive Subcategory Count by categoryId
    Future<int> getSubcategoryCountByCategoryId(String categoryId) async {
        try {
            final response = await _sbdb
                .from('subcategories')
                .select('id')
                .eq('category_id', categoryId)
                .count(CountOption.exact);

            return response.count;
        } catch (e) {
            print('[Error fetching subcategory count]: $e');
            rethrow;
        }
    }

    /// [POST]: Create subcategory
    Future<void> save(Subcategory subcategory) async {
        try {
            await _sbdb.from('subcategories').insert(subcategory.toJson());
        } catch (e) {
            print('[Error creating subcategory]: $e');
            rethrow;
        }
    }

    /// [PUT]: Update subcategory
    Future<void> update(Subcategory subcategory) async {
        try {
            await _sbdb.from('subcategories')
                .update(subcategory.toJson())
                .eq('id', subcategory.id);
        } catch (e) {
            print('[Error updating subcategory]: $e');
            rethrow;
        }
    }

    /// [DELETE]: Delete subcategory
    Future<void> deleteById(String id) async {
        try {
            await _sbdb.from('subcategories').delete().eq('id', id);
        } catch (e) {
            print('[Error deleting subcategory]: $e');
            rethrow;
        }
    }
}