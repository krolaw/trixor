import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

_Settings settings = _Settings();

class _Settings {
  late SharedPreferences sp;
  Completer<void> loaded = Completer<void>();

  bool _vibrate = true;
  int _difficulty = 3;
  bool _sound = true;
  bool _fullscreen = true;

  _Settings() {
    SharedPreferences.getInstance().then((s) {
      _vibrate = s.getBool("vibrate") ?? _vibrate;
      _difficulty = s.getInt("difficulty") ?? _difficulty;
      _sound = s.getBool("sound") ?? _sound;
      _fullscreen = s.getBool("fullscreen") ?? _fullscreen;
      sp = s;
      loaded.complete();
    });
  }

  bool get vibrate => _vibrate;
  set vibrate(bool t) {
    _vibrate = t;
    sp.setBool("vibrate", t);
  }

  bool get sound => _sound;
  set sound(bool t) {
    _sound = t;
    sp.setBool("sound", t);
  }

  bool get fullscreen => _fullscreen;
  set fullscreen(bool t) {
    _fullscreen = t;
    sp.setBool("fullscreen", t);
  }

  int get difficulty => _difficulty;
  set difficulty(int t) {
    _difficulty = t;
    sp.setInt("difficulty", t);
  }
}

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({Key? key}) : super(key: key);

  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: settings.loaded.future,
        builder: (context, builder) => Drawer(
              // Add a ListView to the drawer. This ensures the user can scroll
              // through the options in the drawer if there isn't enough vertical
              // space to fit everything.
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Align(
                        child: Text(
                          'Settings',
                          textScaleFactor: 1.5,
                        ),
                        alignment: Alignment.bottomLeft),
                  ),
                  /*Container(
                      color: Theme.of(context).primaryColor,
                      height: 80,
                      child: Text(
                        'Settings',
                        textScaleFactor: 1.3,
                        //style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      padding: EdgeInsets.fromLTRB(16, 40, 16, 0)),*/
                  CheckboxListTile(
                      title: Text("Sound"),
                      value: settings.sound,
                      onChanged: (b) => setState(() {
                            settings.sound = b == true;
                          })),
                  CheckboxListTile(
                      title: Text("Vibrate"),
                      value: settings.vibrate,
                      onChanged: (b) => setState(() {
                            settings.vibrate = b == true;
                          })),
                  CheckboxListTile(
                      title: Text("Fullscreen"),
                      value: settings.fullscreen,
                      onChanged: (b) => setState(() {
                            settings.fullscreen = b == true;
                          })),
                ],
              ),
            ));
  }
}
