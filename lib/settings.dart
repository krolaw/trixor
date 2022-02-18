import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

_Settings settings = _Settings();

const _defaultColours = [Colors.red, Colors.green, Colors.blue];

class _Settings {
  late SharedPreferences sp;
  Completer<void> loaded = Completer<void>();

  bool _vibrate = true;
  int _difficulty = 3;
  bool _sound = true;
  bool _fullscreen = true;

  List<Color> colours = [Colors.red, Colors.green, Colors.blue];

  _Settings() {
    SharedPreferences.getInstance().then((s) {
      _vibrate = s.getBool("vibrate") ?? _vibrate;
      _difficulty = s.getInt("difficulty") ?? _difficulty;
      _sound = s.getBool("sound") ?? _sound;
      _fullscreen = s.getBool("fullscreen") ?? _fullscreen;

      colours = [
        Color(s.getInt("colour1") ?? colours[0].value),
        Color(s.getInt("colour2") ?? colours[1].value),
        Color(s.getInt("colour3") ?? colours[2].value),
      ];

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

  setColour(int index, Color col) {
    colours[index] = col;
    sp.setInt("colour" + (index + 1).toString(), col.value);
  }
}

class SettingsDrawer extends StatefulWidget {
  final bool changeNow;
  const SettingsDrawer(this.changeNow, {Key? key}) : super(key: key);

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
                            if (widget.changeNow) if (settings.fullscreen)
                              SystemChrome.setEnabledSystemUIMode(
                                  SystemUiMode.immersive);
                            else
                              SystemChrome.setEnabledSystemUIMode(
                                  SystemUiMode.manual,
                                  overlays: SystemUiOverlay.values);
                          })),
                  ListTile(
                    title: Text("Card Backgrounds"),
                    subtitle: Row(children: [
                      TextButton(
                          onPressed: () => getColor(context, 0),
                          child: Container(
                              color: settings.colours[0],
                              width: 30,
                              height: 20)),
                      Spacer(),
                      TextButton(
                          onPressed: () => getColor(context, 1),
                          child: Container(
                              color: settings.colours[1],
                              width: 30,
                              height: 20)),
                      Spacer(),
                      TextButton(
                          onPressed: () => getColor(context, 2),
                          child: Container(
                              color: settings.colours[2],
                              width: 30,
                              height: 20)),
                    ]),
                  ),
                ],
              ),
            ));
  }

  Color pickerColor = settings.colours[0];

  void changeColor(Color color, int index) {
    setState(() => pickerColor = color);
  }

  getColor(BuildContext context, int index) {
    pickerColor = settings.colours[index];
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: SingleChildScrollView(
          child: ColorPicker(
            paletteType: PaletteType.hueWheel,
            enableAlpha: false,
            labelTypes: [],
            pickerColor: pickerColor,
            onColorChanged: (Color c) => changeColor(c, index),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Reset'),
            onPressed: () {
              setState(() => settings.setColour(index, _defaultColours[index]));
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Apply'),
            onPressed: () {
              setState(() => settings.setColour(index, pickerColor));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
