import '../../core/connection/supabase_config.dart';
import '../account/account.dart';

class AccountService {
    final _sbdb = SupabaseConfig.client;

    /// [GET]: Retreives Account List
    Future<List<Account>> getAccountList() async {
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

    /// [POST]: Create Account 
    Future<void> createAccount(Account account) async {
        try {
            await _sbdb.from('accounts')
                .insert(account.toJson());
        } catch (e) {
            print('[Error creating account]: $e');
            rethrow;
        }
    }

    /// [PUT]: Update Account
    Future<void> updateAccount(Account account) async {
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
    Future<void> deleteAccount(String id) async {
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