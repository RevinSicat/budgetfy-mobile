import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceId {
    static const _key = 'device_id';
    static String? _cached;

    /// Returns a stable unique ID for this device/install
    static Future<String> get() async {
        if (_cached != null) return _cached!;

        final prefs = await SharedPreferences.getInstance();
        String? id = prefs.getString(_key);

        if (id == null) {
            id = const Uuid().v4();
            await prefs.setString(_key, id);
        }

        _cached = id;
        return id;
    }
}