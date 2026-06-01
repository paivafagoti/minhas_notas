import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

class ThemeController {
  ThemeController._();

  static const _key = 'theme_mode_v1';

  static Future<AppThemeMode> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    return AppThemeMode.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => AppThemeMode.dark,
    );
  }

  static Future<void> save(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

