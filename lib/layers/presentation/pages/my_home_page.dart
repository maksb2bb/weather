import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/layers/data/models/temperature_data.dart';
import 'package:weather/layers/presentation/widgets/temperature_chart.dart';
import 'package:weather/layers/data/models/weather_data.dart';
import 'package:weather/layers/data/repositories/weather_repository.dart';
import 'package:weather/layers/domain/usecases/get_weather_usecase.dart';
import 'package:weather/layers/presentation/widgets/weather_icons.dart';
import 'package:weather/layers/presentation/pages/about_us_page.dart';
import 'package:weather/layers/presentation/pages/settings_page.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SharedPreferences prefs;
  bool _positive = true;
  bool _speed = true;
  bool _pressure = true;

  WeatherData? _weatherData;

  final GetWeatherUseCase _getWeatherUseCase =
      GetWeatherUseCase(WeatherRepository());

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    _fetchWeatherData();
  }

  Future<void> _initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _positive = prefs.getBool('positive') ?? true;
      _speed = prefs.getBool('speed') ?? true;
      _pressure = prefs.getBool('pressure') ?? true;
    });
  }

  Future<void> _fetchWeatherData() async {
    try {
      WeatherData weatherData = await _getWeatherUseCase.execute();
      setState(() {
        _weatherData = weatherData;
      });
    } catch (e) {
      setState(() {
        _weatherData = null;
      });
    }
  }

  Future<void> _refresh() async {
    await _fetchWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          _weatherData?.city ?? 'Поиск геолокации...',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert),
            iconColor: Colors.white,
            onSelected: (value) {
              if (value == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              } else if (value == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutUSPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return const [
                PopupMenuItem<int>(value: 1, child: Text('Настройки')),
                PopupMenuItem<int>(value: 2, child: Text('О программе')),
              ];
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            color: Colors.blue,
            child: Column(
              children: [
                Align(
                  alignment: const AlignmentDirectional(0, -1),
                  child: _weatherData != null
                      ? Image.asset(
                          weatherIcons[_weatherData!.weatherIcon] ??
                              'assets/images/default.png',
                          height: 200,
                          width: 200,
                        )
                      : const SizedBox.shrink(), // Hide when data is null
                ),
                Align(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            ' ${_weatherData?.temp ?? '0'}° ',
                            style: const TextStyle(
                              fontSize: 70,
                              color: Colors.white,
                            ),
                          ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const ImageIcon(
                                      AssetImage(
                                          "assets/icon/wind_speed_icon.png"),
                                      size: 30,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${_weatherData?.windSpeed ?? '0'} м/ч',
                                      style: const TextStyle(
                                          fontSize: 23, color: Colors.white),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const ImageIcon(
                                      AssetImage("assets/icon/temper.png"),
                                      size: 30,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${_weatherData?.feelsLike ?? '0'}°',
                                      style: const TextStyle(
                                          fontSize: 23, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ]),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height - 330,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(90),
                      topRight: Radius.circular(45),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          'Граффик температуры в течении дня',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 30,
                        height: 300,
                        child: _weatherData != null
                            ? TemperatureChart(
                                _createSampleData(
                                    _weatherData!.temperatureData),
                                animate: true,
                              )
                            : Center(
                                child: MaterialButton(
                                onPressed: _refresh,
                                  color: Colors.blue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
                                clipBehavior: Clip.antiAlias,
                                child: const Text('Обновить'),
                              )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<charts.Series<TemperatureData, DateTime>> _createSampleData(
    List<TemperatureData> data) {
  return [
    charts.Series<TemperatureData, DateTime>(
      id: 'Temperature',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (TemperatureData temps, _) => temps.time,
      measureFn: (TemperatureData temps, _) => temps.tempC,
      data: data,
    )
  ];
}
