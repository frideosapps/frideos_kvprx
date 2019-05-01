import 'package:path/path.dart' as path;

import 'package:sqflite/sqflite.dart' as sqflite;

class DbProvider {
  DbProvider({this.databaseName = 'appdb.db'});

  final String databaseName;
  sqflite.Database db;

  final logs = List<Object>();

  Future<String> getPath() async {
    final databasesPath = await sqflite.getDatabasesPath();
    return path.join(databasesPath, databaseName);
  }

  Future<bool> init() async {
    try {
      db = await sqflite.openDatabase(await getPath());
      return true;
    } catch (e) {
      print(e);
      logs.add(e);
      return false;
    }
  }

  Future<bool> checkDatabaseExists() async {
    final databasesPath = await sqflite.getDatabasesPath();
    final String _path = path.join(databasesPath, databaseName);

    try {
      return await sqflite.databaseExists(_path);
    } catch (e) {
      print(e);
      logs.add(e);
    }
  }

  Future<void> deleteDatabase() async {
    if (await checkDatabaseExists()) {
      final databasesPath = await sqflite.getDatabasesPath();
      final String _path = path.join(databasesPath, databaseName);

      try {
        await sqflite.deleteDatabase(_path);
      } catch (e) {
        print(e);
        logs.add(e);
      }
    }
  }

  Future<int> truncate(String tableName) async {
    try {
      await db.transaction((txn) async {
        return await txn.delete(tableName);
      });
    } catch (e) {
      print(e);
      logs.add(e);
    }
  }

  Future<bool> checkTableExists(String tableName) async {
    try {
      List result;

      result = await db.rawQuery(
          'SELECT * FROM sqlite_master WHERE name =\'$tableName\' and type=\'table\'');

      assert(result != null);

      if (result.isEmpty) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
      logs.add(e);
    }
  }

  Future<void> close() async => db.close();
}
