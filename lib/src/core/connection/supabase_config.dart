import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
    static const String supabaseUrl = 'supabase_url';
    static const String supabaseAnonKey = 'supabase_anon_key';

    static const String envSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
    static const String envSupabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    static bool get isInitialized {
        try {
            Supabase.instance.client;
            return true;
        } catch (_) {
            return false;
        }
    }

    static Future<String?> getUrl() async {
        if (envSupabaseUrl.isNotEmpty) {
            return envSupabaseUrl;
        }
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(supabaseUrl);
    }

    static Future<String?> getAnonKey() async {
        if (envSupabaseAnonKey.isNotEmpty) {
            return envSupabaseAnonKey;
        }
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(supabaseAnonKey);
    }

    static Future<void> saveConfig(String url, String anonKey) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(supabaseUrl, url);
        await prefs.setString(supabaseAnonKey, anonKey);
    }

    static Future<void> clearConfig() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(supabaseUrl);
        await prefs.remove(supabaseAnonKey);
    }

    static Future<bool> init() async {
        final url = await getUrl();
        final anonKey = await getAnonKey();

        if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
            return false;
        }

        try {
            if (Supabase.instance.client != null) {
                return true;
            }
        } catch (_) {
        }

        await Supabase.initialize(url: url, anonKey: anonKey);
        return true;
    }

    static SupabaseClient get client => Supabase.instance.client;
}