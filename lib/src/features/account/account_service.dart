import '../../core/connection/supabase_config.dart';
import '../account/account.dart';

class AccountService {
    final _sbdb = SupabaseConfig.client;

    /// Account List ==============================================================================
    /// [GET]: Retreives Account List
    Future<List<Account>> getAllList() async {
        try {
            final response = await _sbdb.from('accounts')
                .select()
                .order('name', ascending: true);

            return (response as List)
                .map((json) => Account.fromJson(json))
                .toList();
        } catch (e) {
            print('[Error fetching account list]: $e');
            rethrow; 
        }
    }

    /// void Create, Update, Delete ===============================================================
    /// [POST]: Create Account 
    Future<void> save(Account account) async {
        try {
            await _sbdb.from('accounts')
                .insert(account.toJson());
        } catch (e) {
            print('[Error creating account]: $e');
            rethrow;
        }
    }

    /// [PUT]: Update Account
    Future<void> update(Account account) async {
        try {
            await _sbdb.from('accounts')
                .update(account.toJson())
                .eq('id', account.id);
        } catch (e) {
            print('[Error updating account]: $e');
            rethrow;
        }
    }

    /// [DELETE]: Delete Account
    Future<void> deleteById(String id) async {
        try {
            await _sbdb.from('accounts')
                .delete()
                .eq('id', id);
        } catch (e) {
            print('[Error deleting account]: $e');
            rethrow;
        }
    }
}