import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'highscores.dart';
import 'licences.dart';
import 'settings.dart';
import 'game.dart';
import 'about.dart';

void main() {
  LicenseRegistry.addLicense(() => licenses());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TriXOR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        //scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.green,
        brightness: Brightness.dark,
        textTheme: TextTheme(
            headline1: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                height: 2,
                color: Colors.green)),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor: Colors.green,
              primary: Colors.white),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class GameOption {
  final String title;
  final int cols, rows, depth;

  GameOption(this.title, this.cols, this.rows, this.depth);

  static final options = <GameOption>[
    GameOption("Baby", 2, 2, 2),
    GameOption("Very Easy", 2, 2, 3),
    GameOption("Easy", 2, 3, 3),
    GameOption("Normal", 2, 3, 4),
    GameOption("Challenging", 2, 3, 5),
    GameOption("Hard", 2, 4, 4),
    GameOption("Advanced", 2, 4, 5),
    GameOption("Crazy", 3, 4, 4),
    GameOption("Psychotic", 3, 4, 5),
  ];
}

class CardOption {
  final int cols, rows;

  CardOption(this.cols, this.rows);

  get count => cols * rows;
}

class _MyHomePageState extends State<MyHomePage> {
  /*static final cardOptions = <CardOption>[
    CardOption(2, 2),
    CardOption(2, 3),
    CardOption(2, 4),
    CardOption(3, 3),
    CardOption(2, 5),
    CardOption(3, 4),
    CardOption(3, 5),
    CardOption(4, 4),
  ];

  
  static int cardOption = 2;
  static int properties = 3;*/

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: FutureBuilder<String>(
            initialData: "",
            future: PackageInfo.fromPlatform().then((a) => a.version),
            builder: (context, value) => Text("TriXOR V" + value.data!)),
      ),
      drawer: SettingsDrawer(),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.

        child: IntrinsicWidth(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
              Stack(children: [
                Text("Difficulty"),
                Container(
                    padding: EdgeInsets.only(top: 5),
                    child: FutureBuilder(
                        future: settings.loaded.future,
                        builder: (context, _) => Slider(
                              value: settings.difficulty.toDouble(),
                              min: 0,
                              max: GameOption.options.length - 1,
                              divisions: GameOption.options.length - 1,
                              label:
                                  GameOption.options[settings.difficulty].title,
                              onChanged: (v) => setState(
                                  () => settings.difficulty = v.toInt()),
                            )))
              ]),
              /*Stack(children: [
                Text("Cards"),
                Container(
                    padding: EdgeInsets.only(top: 5),
                    child: Slider(
                      value: cardOption.toDouble(),
                      min: 0,
                      max: cardOptions.length - 1,
                      divisions: cardOptions.length - 1,
                      label: cardOptions[cardOption].count.toString(),
                      onChanged: (v) => setState(() => cardOption = v.toInt()),
                    ))
              ]),
              Stack(children: [
                Text("Properties"),
                Container(
                    padding: EdgeInsets.only(top: 5),
                    child: Slider(
                      value: properties.toDouble(),
                      min: 2,
                      max: 5,
                      divisions: 3,
                      label: properties.toString(),
                      onChanged: (v) => setState(() => properties = v.toInt()),
                    ))
              ]),*/

              //Divider(),
              TextButton(
                  child: Text("Play"),
                  onPressed: () =>
                      loadGame(context, settings.difficulty, false)),
              /* onPressed: () => loadGame2(
                      context, cardOptions[cardOption], properties, false)),*/
              TextButton(
                  child: Text("Practise"),
                  onPressed: () =>
                      loadGame(context, settings.difficulty, true)),
              TextButton(
                  child: Text("About"),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HowToPlay()))),
              TextButton(
                  child: Text("High Scores"),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HighscoresView()))),
            ])),
      ),
    );
  }

  loadGame(BuildContext context, int level, bool practise) {
    final GameOption g = GameOption.options[level];
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SafeArea(
                child: Game(level, g.cols, g.rows, g.depth, practise))));
  }
}
