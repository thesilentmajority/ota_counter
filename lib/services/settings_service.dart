import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _gridSizeKey = 'grid_size';
  static const double defaultGridSize = 3;
  
  static Future<void> saveGridSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_gridSizeKey, size);
  }
  
  static Future<double> getGridSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_gridSizeKey) ?? defaultGridSize;
  }
} 