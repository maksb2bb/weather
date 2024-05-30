import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather/settings.dart';

import 'aboutUS.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  String _data = "Loading...";
  String _City = "Loading...";
  String _temp = "0";
  int _isday = 1;
  String _windspd = "0";
  String _feelslike = "0";

  @override
  void initState() {
    super.initState();
    _determineUserLocation();
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
      _City = city;
    });

    // Fetch weather data after determining the city
    await _fetchData();
  }

  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse(
        "http://api.weatherapi.com/v1/current.json?key=1da3b4d034324980974174540242405&q=$_City"));
    if (response.statusCode == 200) {
      setState(() {
        _data = response.body;
      });
      await _decode();
      await _day();
      await _wind();
      await _feel();
    } else {
      setState(() {
        _data = 'Request failed with status: ${response.statusCode}.';
      });
    }
  }

  Future<void> _decode() async {
    var tempMap = json.decode(_data);
    setState(() {
      _temp = tempMap['current']['temp_c'].round().toString();
    });
  }

  Future<void> _day() async {
    var dayMap = json.decode(_data);
    setState(() {
      _isday = dayMap['current']['is_day'];
    });
  }

  Future<void> _wind() async {
    var windMap = json.decode(_data);
    setState(() {
      _windspd = windMap['current']['wind_kph'].toString();
    });
  }

  Future<void> _feel() async {
    var feelMap = json.decode(_data);
    setState(() {
      _feelslike = feelMap['current']['feelslike_c'].toString();
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
          _City,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  child: _isday == 0
                      ? Image.asset("assets/images/Moon.png")
                      : Image.asset("assets/images/Sunny.png"),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        '$_temp° ',
                        style: const TextStyle(fontSize: 90, color: Colors.white),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const ImageIcon(AssetImage("assets/icon/wind_speed_icon.png")),
                              Text(
                                '$_windspd км/ч',
                                style: const TextStyle(fontSize: 23, color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const ImageIcon(AssetImage("assets/icon/temper.png")),
                              Text(
                                '$_feelslike°',
                                style: const TextStyle(fontSize: 23, color: Colors.white),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height - kToolbarHeight,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(90),
                      topRight: Radius.circular(45),
                    ),
                  ),
                  child: Column(
                    children: const [
                      Text("Hellow"),
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
