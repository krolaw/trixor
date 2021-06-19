import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Highscores {
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

  Future<bool> isHighScore(int level, int score) async =>
      (await (await db).query('highscores',
              columns: ['COUNT(id) as count'],
              where: 'level=? AND score>?',
              whereArgs: [level, score]))
          .first['count']! as int <
      10;

  //Future<String> lastName() async =>
  //  (await )
}
