import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/layers/domain/enities/settings_entity.dart';
import 'package:weather/layers/domain/usecases/get_settings.dart';
import 'package:weather/layers/domain/usecases/save_settings.dart';
import 'package:weather/layers/data/repositories/settings_repository.dart';
import 'package:weather/layers/domain/usecases/get_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ValueNotifier<bool> _positive;
  late ValueNotifier<bool> _speed;
  late ValueNotifier<bool> _pressure;
  late GetSettings _getSettings;
  late SaveSettings _saveSettings;
  String? _theme;

  @override
  void initState() {
    super.initState();
    final repository = SettingsRepository();
    _getSettings = GetSettings(repository);
    _saveSettings = SaveSettings(repository);
    _initializePreferences();
  }


  Future<void> _initializePreferences() async {
    final settings = await _getSettings.execute();

    _positive = ValueNotifier<bool>(settings.positive);
    _speed = ValueNotifier<bool>(settings.speed);
    _pressure = ValueNotifier<bool>(settings.pressure);
    _theme = settings.theme;

    _positive.addListener(() {
      _saveSettings.execute(
        Settings(
          positive: _positive.value,
          speed: _speed.value,
          pressure: _pressure.value,
          theme: _theme!,
        ),
      );
    });
    _speed.addListener(() {
      _saveSettings.execute(
        Settings(
          positive: _positive.value,
          speed: _speed.value,
          pressure: _pressure.value,
          theme: _theme!,
        ),
      );
    });
    _pressure.addListener(() {
      _saveSettings.execute(
        Settings(
          positive: _positive.value,
          speed: _speed.value,
          pressure: _pressure.value,
          theme: _theme!,
        ),
      );
    });

    setState(() {}); // to rebuild UI after loading preferences
  }

  void _setTheme(String? value) {
    setState(() {
      _theme = value;
    });
    _saveSettings.execute(
      Settings(
        positive: _positive.value,
        speed: _speed.value,
        pressure: _pressure.value,
        theme: value!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_theme == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'Настройки',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
        backgroundColor: Colors.white70,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'Настройки',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            children: <Widget>[
              Text(
                'Единицы измерения',
                style: TextStyle(fontSize: 13,
                height: 4),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  children: <Widget>[
                    Text(
                      "Температура",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Spacer(),
                    AdvancedSwitch(
                      enabled: true,
                      controller: _positive,
                      activeColor: Colors.deepOrange,
                      inactiveColor: Colors.grey,
                      activeChild: Text('°C'),
                      inactiveChild: Text('°F'),
                      borderRadius: BorderRadius.all(Radius.circular(60)),
                      width: 80,
                      height: 35,
                      initialValue: _positive.value,
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Text(
                      "Сила ветра",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Spacer(),
                    AdvancedSwitch(
                      controller: _speed,
                      activeColor: Colors.deepOrange,
                      inactiveColor: Colors.grey,
                      activeChild: Text('км/ч'),
                      inactiveChild: Text('м/с'),
                      borderRadius: BorderRadius.all(Radius.circular(60)),
                      width: 80,
                      height: 35,
                      initialValue: _speed.value,
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Text(
                      "Давление",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Spacer(),
                    AdvancedSwitch(
                      controller: _pressure,
                      activeColor: Colors.deepOrange,
                      inactiveColor: Colors.grey,
                      activeChild: Text('рт.ст'),
                      inactiveChild: Text('гПа'),
                      borderRadius: BorderRadius.all(Radius.circular(60)),
                      width: 80,
                      height: 35,
                      initialValue: _pressure.value,
                    ),
                  ],
                ),
              ),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Тема оформления',
                        style: TextStyle(fontSize: 13, color: Colors.black),
                      ),
                      Row(
                        children: [
                          Text(
                            'Светлая',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          Spacer(),
                          Radio<String>(
                              fillColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.deepOrange),
                              focusColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.deepOrange),
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
                              fontSize: 14,
                            ),
                          ),
                          Spacer(),
                          Radio<String>(
                              fillColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.deepOrange),
                              focusColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.deepOrange),
                              value: 'Night',
                              groupValue: _theme,
                              onChanged: _setTheme

                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Как в системе',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          Spacer(),
                          Radio<String>(
                              fillColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.deepOrange),
                              focusColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.deepOrange),
                              value: 'System',
                              groupValue: _theme,
                              onChanged: _setTheme)
                        ],
                      )
                    ],
                  )
              ),
            ],
          ),
        )
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
