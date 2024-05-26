import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/aboutUS.dart';
import 'settings.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

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
      return Future.error('Location services are disabled.');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          _City,
          style:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<int>(
            icon: Icon(Icons.more_vert),
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
      body: Scaffold(
        backgroundColor: Colors.blue,
        body: Column(
          children: [
            Align(
              alignment: const AlignmentDirectional(0, -1),
              child: _isday == 0
                  ? Image.asset("assets/images/Moon.png")
                  : Image.asset("assets/images/Sunny.png"),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$_temp°',
                style: const TextStyle(fontSize: 90, color: Colors.white),
              ),
            ),
            Expanded(
              child: Align(
                alignment: const AlignmentDirectional(0, 1),
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      topLeft: Radius.circular(90),
                      topRight: Radius.circular(45),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        //mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text(
                            "Скорость ветра:    ",
                            style: TextStyle(fontSize: 25, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '$_windspd км/ч',
                            style: TextStyle(fontSize: 25, color: Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        //mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text(
                            "Ощущается как:    ",
                            style: TextStyle(fontSize: 25, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "$_feelslike°",
                            style: TextStyle(fontSize: 25, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
