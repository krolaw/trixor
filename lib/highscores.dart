import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trixor/main.dart';

var highscores = Highscores();

class Highscores {
  static const scoresLimit = 10;

  Future<Database> db;

  Highscores()
      : db = getDatabasesPath().then((path) => openDatabase(
            join(path, 'triXOR.db'),
            version: 1,
            onCreate: (db, version) => db.execute('''CREATE TABLE highscores (
        id INTEGER PRIMARY KEY NOT NULL,
        level INTEGER,
        name TEXT NOT NULL,
        score INTEGER NOT NULL,
        at INTEGER NOT NULL DEFAULT (strftime('%s',CURRENT_TIMESTAMP))
      )''')));

  Future<String?> isHighScore(int level, int score) async {
    if (score == 0) return null;
    var bd = await db;
    if ((await bd.query('highscores',
                columns: ['COUNT(id) as count'],
                where: 'level=? AND score>=?',
                whereArgs: [level, score]))
            .first['count']! as int >=
        scoresLimit) return null;
    var r = (await bd.query('highscores',
        columns: ['name'], limit: 1, orderBy: 'at DESC'));
    return r.isEmpty ? "" : r.first['name'] as String;
  }

  Future<void> saveHighScore(int level, int score, String name) async {
    var bd = await db;
    await bd
        .insert('highscores', {'level': level, 'score': score, 'name': name});
    (await getHighScoresLevel(level)).skip(scoresLimit).forEach(
        (e) => bd.delete('highscores', where: "id=?", whereArgs: [e["id"]]));
  }

  Future<List<Map<String, Object?>>> getHighScores() async {
    return await (await db).rawQuery(
        '''select level, score, strftime('%Y-%m-%d %H:%M',at,'unixepoch','localtime') at, name'''
        ' from highscores order by level DESC, score DESC, at DESC;');
  }

  Future<List<Map<String, Object?>>> getHighScoresLevel(int level) async {
    return await (await db).query('highscores',
        columns: ['id', 'level, score, at, name'],
        where: 'level = ?',
        whereArgs: [level],
        orderBy: "level DESC, score DESC, at DESC");
  }
}

class HighscoresView extends StatelessWidget {
  const HighscoresView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("TriXOR : High Scores")),
        body: FutureBuilder<List<Map<String, Object?>>>(
            future: highscores.getHighScores(),
            builder: (context, h) {
              int currentLevel = -1;
              return ListView(children: [
                DataTable(dataRowHeight: 30, headingRowHeight: 30, columns: [
                  DataColumn(label: Text("Date")),
                  DataColumn(label: Text("Name")),
                  DataColumn(label: Text("Score"), numeric: true)
                ], rows: [
                  ...(h.data?.expand<DataRow>((e) {
                        final level = e['level'] as int;
                        final head = currentLevel != level;
                        currentLevel = level;
                        return [
                          if (head)
                            DataRow(
                                color: MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) =>
                                        Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.5)),
                                cells: [
                                  DataCell(
                                      Text(GameOption.options[level].title)),
                                  DataCell(Container()),
                                  DataCell(Container())
                                ]),
                          DataRow(cells: [
                            DataCell(Text(e['at'].toString())),
                            DataCell(Text(e['name'].toString())),
                            DataCell(Text(
                              e['score'].toString(),
                              textAlign: TextAlign.end,
                            ))
                          ])
                        ];
                      }) ??
                      [])
                ])
              ]);
            }));
  }
}
