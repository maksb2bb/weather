import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/layers/data/models/weather_data.dart';
import 'package:weather/layers/data/models/temperature_data.dart';

class WeatherRepository {
  final String apiKey = '1da3b4d034324980974174540242405';

  Future<WeatherData> fetchWeather(String city) async {
    final response = await http.get(Uri.parse(
        "http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&days=1"));
    if (response.statusCode == 200) {
      return WeatherData.fromJSON(json.decode(response.body));
    } else {
      throw Exception('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<String> determineUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      'android.settings.LOCATION_SOURCE_SETTINGS';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);
    return placemarks.first.locality ?? 'Unknown';
  }
}
