import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/settings.dart';
import 'aboutUS.dart';
import 'weather_icons.dart'; // Import the weatherIcons map
import 'package:charts_flutter/flutter.dart' as charts;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class TemperatureData {
  final DateTime time;
  final double tempC;

  TemperatureData(this.time, this.tempC);

  factory TemperatureData.fromJSON(Map<String, dynamic> json) {
    return TemperatureData(
        DateTime.parse(json['time']), json['temp_c'].toDouble());
  }
}

class TemperatureChart extends StatelessWidget {
  final List<charts.Series<TemperatureData, DateTime>> seriesList;
  final bool animate;

  TemperatureChart(this.seriesList, {required this.animate});

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(zeroBound: false),
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
            fontSize: 12,
            color: charts.MaterialPalette.black,
          ),
          lineStyle: charts.LineStyleSpec(
            thickness: 1,
            color: charts.MaterialPalette.gray.shade300,
          ),
        ),
      ),
      domainAxis: charts.DateTimeAxisSpec(
        tickProviderSpec: charts.AutoDateTimeTickProviderSpec(),
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
            fontSize: 12,
            color: charts.MaterialPalette.black,
          ),
          lineStyle: charts.LineStyleSpec(
            thickness: 1,
            color: charts.MaterialPalette.gray.shade300,
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

class _MyHomePageState extends State<MyHomePage> {
  String _data = "Loading...";
  String _city = "Loading...";
  String _temp = "0";
  int _weathericon = 1;
  String _windspd = "0";
  String _feelslike = "0";
  late SharedPreferences prefs;
  bool _positive = true;
  bool _speed = true;
  bool _pressure = true;
  List<TemperatureData> _temperatureData = []; // Store temperature data

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    _determineUserLocation();
  }

  Future<void> _initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _positive = prefs.getBool('positive') ?? true;
      _speed = prefs.getBool('speed') ?? true;
      _pressure = prefs.getBool('pressure') ?? true;
    });
  }

  Future<void> _determineUserLocation() async {
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
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    String city = placemarks.first.locality ?? 'Unknown';

    setState(() {
      _city = city;
    });

    // Fetch weather data after determining the city
    await _fetchData();
  }

  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse(
        "http://api.weatherapi.com/v1/forecast.json?key=1da3b4d034324980974174540242405&q=$_city&days=1"));
    if (response.statusCode == 200) {
      setState(() {
        _data = response.body;
      });
      await _decode();
      await _day();
      await _wind();
      await _feel();
      await _generateTemperatureData(); // Generate temperature data
    } else {
      setState(() {
        _data = 'Request failed with status: ${response.statusCode}.';
      });
    }
  }

  Future<void> _decode() async {
    var tempMap = json.decode(_data);
    setState(() {
      _temp = _positive
          ? tempMap['current']['temp_c'].round().toString()
          : tempMap['current']['temp_f'].round().toString();
    });
  }

  Future<void> _day() async {
    var dayMap = json.decode(_data);
    setState(() {
      _weathericon = dayMap['current']['condition']['code'];
    });
  }

  Future<void> _wind() async {
    var windMap = json.decode(_data);
    setState(() {
      _windspd = _positive
          ? windMap['current']['wind_kph'].toString()
          : windMap['current']['wind_mph'].toString();
    });
  }

  Future<void> _feel() async {
    var feelMap = json.decode(_data);
    setState(() {
      _feelslike = _speed
          ? feelMap['current']['feelslike_c'].toString()
          : feelMap['current']['feelslike_f'].toString();
    });
  }

  Future<void> _generateTemperatureData() async {
    var forecastData = json.decode(_data)['forecast']['forecastday'][0]['hour'];
    List<TemperatureData> tempData = [];
    for (var hourData in forecastData) {
      tempData.add(TemperatureData.fromJSON(hourData));
    }
    // Debugging: Print the parsed temperature data
    tempData.forEach((data) {
      print('Time: ${data.time}, Temp: ${data.tempC}');
    });
    setState(() {
      _temperatureData = tempData;
    });
  }

  Future<void> _refresh() async {
    await _determineUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          _city,
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
                  child: Image.asset(
                    weatherIcons[_weathericon] ?? 'assets/images/default.png',
                    height: 200, // Adjust the size as needed
                    width: 200, // Adjust the size as needed
                  ),
                ),
                Align(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '$_temp° ',
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
                                      '$_windspd м/ч',
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
                                      '$_feelslike°',
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
                  height: MediaQuery.of(context).size.height - kToolbarHeight,
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
                        width: MediaQuery.of(context).size.width - 50,
                        height: 300, // Adjust the height as needed
                        child: TemperatureChart(
                          _createSampleData(_temperatureData),
                          animate: true,
                        ),
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
