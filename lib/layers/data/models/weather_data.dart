import 'temperature_data.dart';

class WeatherData {
  final String city;
  final int weatherIcon;
  final String temp;
  final String windSpeed;
  final String feelsLike;
  final List<TemperatureData> temperatureData;

  WeatherData({
    required this.city,
    required this.weatherIcon,
    required this.temp,
    required this.windSpeed,
    required this.feelsLike,
    required this.temperatureData,
  });

  factory WeatherData.fromJSON(Map<String, dynamic> json){
    List<TemperatureData> tempData = [];
    for (var hourData in json['forecast']['forecastday'][0]['hour']) {
      tempData.add(TemperatureData.fromJSON(hourData));
    }

    return WeatherData(
      city: json['location']['name'],
      weatherIcon: json['current']['condition']['code'],
      temp: json['current']['temp_c'].round().toString(),
      windSpeed: json['current']['wind_kph'].toString(),
      feelsLike: json['current']['feelslike_c'].toString(),
      temperatureData: tempData,
    );
  }
}