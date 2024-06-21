import 'package:weather/layers/data/repositories/weather_repository.dart';
import 'package:weather/layers/data/models/weather_data.dart';

class GetWeatherUseCase{
  final WeatherRepository repository;

  GetWeatherUseCase(this.repository);

  Future<WeatherData> execute() async{
    String city = await repository.determineUserLocation();
    return await repository.fetchWeather(city);
  }
}