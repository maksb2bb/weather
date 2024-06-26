import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/layers/domain/enities/settings_entity.dart';

class SettingsRepository {
  Future<Settings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final positive = prefs.getBool('positive') ?? true;
    final speed = prefs.getBool('speed') ?? false;
    final pressure = prefs.getBool('pressure') ?? true;
    final theme = prefs.getString('theme') ?? 'System';

    return Settings(
      positive: positive,
      speed: speed,
      pressure: pressure,
      theme: theme,
    );
  }

  Future<void> saveSettings(Settings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('positive', settings.positive);
    await prefs.setBool('speed', settings.speed);
    await prefs.setBool('pressure', settings.pressure);
    await prefs.setString('theme', settings.theme);
  }
}