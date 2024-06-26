import 'package:weather/layers/data/repositories/settings_repository.dart';
import 'package:weather/layers/domain/enities/settings_entity.dart';


class GetSettings{
  final SettingsRepository repository;

  GetSettings(this.repository);

  Future<Settings> execute() async{
    return await repository.getSettings();
  }
}