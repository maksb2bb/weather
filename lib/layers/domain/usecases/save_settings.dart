import 'package:weather/layers/data/repositories/settings_repository.dart';
import 'package:weather/layers/domain/enities/settings_entity.dart';



class SaveSettings{
  final SettingsRepository repository;

  SaveSettings(this.repository);

  Future<void> execute(Settings settings) async{
    await repository.saveSettings(settings);
  }
}