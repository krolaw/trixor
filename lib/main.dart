import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'game.dart';
import 'about.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TriXOR',
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
                backgroundColor: Colors.green, primary: Colors.white),
          )),
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
}

class _MyHomePageState extends State<MyHomePage> {
  static final gameOptions = <GameOption>[
    GameOption("Very Easy", 2, 2, 2),
    GameOption("Easy", 2, 3, 3),
    GameOption("Normal", 2, 4, 4),
    GameOption("Hard", 2, 4, 5),
    GameOption("Harder", 3, 3, 5),
    GameOption("Crazy", 3, 4, 5),
  ];

  int gameOption = 2;

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
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.

        child: IntrinsicWidth(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
              Text("Difficulty"),
              Slider(
                value: gameOption.toDouble(),
                min: 0,
                max: gameOptions.length - 1,
                divisions: gameOptions.length - 1,
                label: gameOptions[gameOption].title,
                onChanged: (v) => setState(() => gameOption = v.toInt()),
              ),
              //Divider(),
              TextButton(
                  child: Text("Play"),
                  onPressed: () =>
                      loadGame(context, gameOptions[gameOption], false)),
              TextButton(
                  child: Text("Practise"),
                  onPressed: () =>
                      loadGame(context, gameOptions[gameOption], true)),
              TextButton(
                  child: Text("About"),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HowToPlay()))),
              TextButton(child: Text("High Scores"), onPressed: () {}),
            ])),
      ),
    );
  }

  loadGame(BuildContext context, GameOption g, bool practise) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Game(g.cols, g.rows, g.depth, practise)));
  }
}
