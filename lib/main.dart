import 'dart:async';

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

  @override
  void initState() {
    super.initState();
    _determineUserLocation();
    _fetchData();
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
  }

  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse(
        "http://api.weatherapi.com/v1/current.json?key=1da3b4d034324980974174540242405&q=$_City"));
    if (response.statusCode == 200) {
      setState(() {
        print(response.body);
      });
    } else {
      setState(() {
        print('Request failed with status: ${response.statusCode}.');
      });
    }
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
              } else if (value == 3) {}
            },
            itemBuilder: (BuildContext context) {
              return const [
                PopupMenuItem<int>(value: 1, child: Text('Настройки')),
                PopupMenuItem<int>(value: 2, child: Text('О программе')),
                PopupMenuItem<int>(value: 3, child: Text('Отправить запрос')),
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
              alignment: AlignmentDirectional(0, -1),
              child: Image.asset("assets/images/Moon.png"),
            ),
            Expanded(
                child: Align(
                  alignment: AlignmentDirectional(0, 1),
                  child: Container(
                    width: double.infinity,
                    height: 400,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                        topLeft: Radius.circular(90),
                        topRight: Radius.circular(45),
                      ),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
