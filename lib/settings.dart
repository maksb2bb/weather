import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ValueNotifier<bool> _positive;
  late ValueNotifier<bool> _speed;
  late ValueNotifier<bool> _pressure;
  SharedPreferences? prefs;
  String? _theme;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    _positive = ValueNotifier<bool>(prefs!.getBool('positive') ?? true);
    _speed = ValueNotifier<bool>(prefs!.getBool('speed') ?? false);
    _pressure = ValueNotifier<bool>(prefs!.getBool('pressure') ?? true);
    _theme = prefs!.getString('theme') ?? 'System';

    _positive.addListener(() {
      prefs!.setBool('positive', _positive.value);
    });
    _speed.addListener(() {
      prefs!.setBool('speed', _speed.value);
    });
    _pressure.addListener(() {
      prefs!.setBool('pressure', _pressure.value);
    });

    setState(() {}); // to rebuild UI after loading preferences
  }

  void _setTheme(String? value) {
    setState(() {
      _theme = value;
    });
    prefs!.setString('theme', value!);
  }

  @override
  Widget build(BuildContext context) {
    if (prefs == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'Настройки',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Настройки',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(3.0)),
          Text(
            'Единицы измерения',
            style: TextStyle(fontSize: 13),
          ),
          Divider(
            color: Colors.black26,
            thickness: 1,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Температура",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Spacer(),
              AdvancedSwitch(
                controller: _positive,
                activeColor: Colors.deepOrange,
                inactiveColor: Colors.deepOrange,
                activeChild: Text('°C'),
                inactiveChild: Text('°F'),
                borderRadius: BorderRadius.all(Radius.circular(0)),
                width: 80,
                height: 35,
              )
            ],
          ),
          Divider(
            color: Colors.black26,
            thickness: 3,
          ),
          Row(
            children: [
              Text(
                "Сила ветра",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Spacer(),
              AdvancedSwitch(
                controller: _speed,
                activeColor: Colors.yellow,
                inactiveColor: Colors.yellow,
                activeChild: Text('км/ч'),
                inactiveChild: Text('м/с'),
                borderRadius: BorderRadius.all(Radius.circular(0)),
                width: 80,
                height: 35,
              )
            ],
          ),
          Divider(
            color: Colors.black26,
            thickness: 3,
          ),
          Row(
            children: [
              Text(
                "Давление",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Spacer(),
              AdvancedSwitch(
                controller: _pressure,
                activeColor: Colors.green,
                inactiveColor: Colors.green,
                activeChild: Text('рт.ст'),
                inactiveChild: Text('гПа'),
                borderRadius: BorderRadius.all(Radius.circular(0)),
                width: 80,
                height: 35,
              ),
            ],
          ),
          Divider(
            color: Colors.black26,
            thickness: 1,
          ),
          Text(
            'Тема оформления',
            style: TextStyle(fontSize: 13),
          ),
          Divider(
            color: Colors.black26,
            thickness: 1,
          ),
          Column(
            children: <Widget>[
              Row(
                children: [
                  Text(
                    'Светлая',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Spacer(),
                  Radio<String>(
                      fillColor: MaterialStateColor.resolveWith(
                              (states) => Colors.grey),
                      focusColor: MaterialStateColor.resolveWith(
                              (states) => Colors.blue),
                      value: 'Day',
                      groupValue: _theme,
                      onChanged: _setTheme)
                ],
              ),
              Row(
                children: [
                  Text(
                    'Тёмная',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Spacer(),
                  Radio<String>(
                      fillColor: MaterialStateColor.resolveWith(
                              (states) => Colors.grey),
                      focusColor: MaterialStateColor.resolveWith(
                              (states) => Colors.blue),
                      value: 'Night',
                      groupValue: _theme,
                      onChanged: _setTheme)
                ],
              ),
              Row(
                children: [
                  Text(
                    'Как в системе',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Spacer(),
                  Radio<String>(
                      fillColor: MaterialStateColor.resolveWith(
                              (states) => Colors.grey),
                      focusColor: MaterialStateColor.resolveWith(
                              (states) => Colors.blue),
                      value: 'System',
                      groupValue: _theme,
                      onChanged: _setTheme)
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _positive.dispose();
    _speed.dispose();
    _pressure.dispose();
    super.dispose();
  }
}




