import 'package:meta/meta.dart';

import 'dbprovider.dart';
import 'models/keyvalue_model.dart';

/// KeyValueProvider class (TODO)
///
/// By default the table name is set to 'kvp'.
///
class KeyValueProvider {
  KeyValueProvider({@required this.dbProvider, this.table = 'kvp'}) {
    assert(dbProvider != null);

    createTable = '''
        CREATE TABLE $table ( 
          id integer primary key autoincrement, 
          key text UNIQUE not null,
          value text);
        CREATE UNIQUE INDEX idx_${table}_id ON $table (id);
        CREATE UNIQUE INDEX idx_${table}_key ON $table (key);
        ''';
  }

  final DbProvider dbProvider;
  final String table;
  String createTable;

  Future<bool> init() async {
    try {
      var exists = await dbProvider.checkTableExists(table);
      assert(exists != null);

      if (!exists) {
        await dbProvider.db.execute(createTable);
      }

      return true;
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
      return false;
    }
  }

  Future<List<KeyValue>> getAll() async {
    final query = 'SELECT * FROM $table';

    List<KeyValue> pairs = [];

    final result = await dbProvider.db.rawQuery(query);
    if (result.isNotEmpty) {
      for (var r in result) {
        pairs.add(KeyValue.fromMap(r));
      }
    }

    return pairs;
  }

  Future<KeyValue> getKeyValue(KeyValue kvp) async {
    assert(kvp != null && kvp.id != null);

    KeyValue dbKey;
    final query = 'SELECT * FROM $table WHERE id = ?';

    try {
      final result = await dbProvider.db.rawQuery(query, [kvp.id]);
      if (result.isNotEmpty) {
        dbKey = KeyValue.fromMap(result.first);
      }
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
    }

    return dbKey;
  }

  Future<KeyValue> getById(int id) async {
    assert(id != null);

    KeyValue dbKey;
    final query = 'SELECT * FROM $table WHERE id = ?';

    try {
      final result = await dbProvider.db.rawQuery(query, [id]);
      if (result.isNotEmpty) {
        dbKey = KeyValue.fromMap(result.first);
      }
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
    }

    return dbKey;
  }

  Future<KeyValue> getByKey(String key) async {
    assert(key != null);

    KeyValue dbKey;
    final query = 'SELECT * FROM $table WHERE key = ?';

    try {
      final result = await dbProvider.db.rawQuery(query, [key]);
      if (result.isNotEmpty) {
        dbKey = KeyValue.fromMap(result.first);
      }
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
    }

    return dbKey;
  }

  Future<KeyValue> insert(KeyValue kvp) async {
    assert(kvp.key != null);

    try {
      await dbProvider.db.insert(table, kvp.toMap());
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
    }

    return kvp;
  }

  Future<bool> insertKeyValue(String key, String value) async {
    assert(key != null);

    try {
      await dbProvider.db.execute('''
        INSERT INTO $table (key, value) 
        VALUES  (?, ?); 
        ''', [key, value]);
      return true;
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
    }

    return false;
  }

  Future<int> update(KeyValue kvp, String value) async {
    assert(kvp != null);

    try {
      final query = 'UPDATE $table SET value = ? WHERE id = ?';
      return await dbProvider.db.rawUpdate(query, [value, kvp.id]);
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
      return -1;
    }
  }

  Future<int> updateById(int id, String value) async {
    assert(id != null);

    try {
      final query = 'UPDATE $table SET value = ? WHERE id = ?';
      return await dbProvider.db.rawUpdate(query, [value, id]);
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
      return -1;
    }
  }

  Future<int> updateByKey(String key, String value) async {
    assert(key != null);

    try {
      final query = 'UPDATE $table SET value = ? WHERE key = ?';
      return await dbProvider.db.rawUpdate(query, [value, key]);
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
      return -1;
    }
  }

  Future<int> delete(KeyValue kvp) async {
    assert(kvp != null);

    try {
      return await dbProvider.db
          .delete(table, where: 'id = ?', whereArgs: [kvp.id]);
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
      return -1;
    }
  }

  Future<int> deleteById(int id) async {
    assert(id != null);

    try {
      return await dbProvider.db
          .delete(table, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
      return -1;
    }
  }

  Future<int> deleteByKey(String key) async {
    assert(key != null);

    try {
      return await dbProvider.db
          .delete(table, where: 'key = ?', whereArgs: [key]);
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
      return -1;
    }
  }

  Future<void> bulkInsert(List<KeyValue> kvps) async {
    String sql = 'INSERT INTO $table (key, value) VALUES';
    String sqlArgs = '';
    List<dynamic> args = [];

    for (var kvp in kvps) {
      sqlArgs += ' (? , ?) ';

      if (kvps.indexOf(kvp) < kvps.length - 1) {
        sqlArgs += ',';
      }

      args.add(kvp.key);
      args.add(kvp.value);
    }

    sql += sqlArgs;

    try {
      await dbProvider.db.transaction((txn) async {
        await txn.execute(sql, args);
      });
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
    }
  }

  Future<void> insertMap(Map<String, String> map) async {
    String sql = 'INSERT INTO $table (key, value) VALUES';
    String sqlArgs = '';
    List<dynamic> args = [];

    int i = 0;
    map.forEach((key, value) {
      sqlArgs += ' (? , ?) ';

      if (i < map.length - 1) {
        sqlArgs += ',';
      }

      args..add(key)..add(value);

      i++;
    });

    sql += sqlArgs;

    try {
      await dbProvider.db.transaction((txn) async {
        await txn.execute(sql, args);
      });
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
    }
  }

  Future<void> bulkDelete(List<KeyValue> kvps) async {
    String sql = 'DELETE FROM $table WHERE id IN (';
    String sqlArgs = '';
    List<dynamic> args = [];

    for (var kvp in kvps) {
      sqlArgs += ' ? ';

      if (kvps.indexOf(kvp) < kvps.length - 1) {
        sqlArgs += ' , ';
      } else {
        sqlArgs += ' ) ';
      }

      args.add(kvp.id);
    }

    sql += sqlArgs;

    try {
      await dbProvider.db.transaction((txn) async {
        await txn.execute(sql, args);
      });
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
    }
  }

  Future<void> bulkDeleteKeys(List<String> keys) async {
    String sql = 'DELETE FROM $table WHERE key IN (';
    String sqlArgs = '';
    List<dynamic> args = [];

    for (var key in keys) {
      sqlArgs += ' ? ';

      if (keys.indexOf(key) < keys.length - 1) {
        sqlArgs += ' , ';
      } else {
        sqlArgs += ' ) ';
      }

      args.add(key);
    }

    sql += sqlArgs;

    try {
      await dbProvider.db.transaction((txn) async {
        await txn.execute(sql, args);
      });
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
    }
  }

  Future<void> bulkUpdate(List<KeyValue> kvps) async {
    try {
      await dbProvider.db.transaction((txn) async {
        var batch = txn.batch();

        for (var kvp in kvps) {
          batch.update(table, kvp.toMap(),
              where: 'key = ?', whereArgs: [kvp.key]);
        }
        await batch.commit(noResult: true);
      });
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
    }
  }

  Future<int> truncate() async => await dbProvider.truncate(table);
}
