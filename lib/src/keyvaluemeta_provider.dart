import 'package:meta/meta.dart';

import 'dbprovider.dart';
import 'models/keyvaluemeta_model.dart';

/// KeyValueMetaProvider class
///
/// By default the table name is set to 'kvpmeta'. It is important to notice
/// that if more [KeyValueProvider] are created with the default table name,
/// both the `getAll` and `truncate` method will affects all the records.
/// To avoid this behavior, use the `table` paramater to give to each provider
/// a different table name.
///
class KeyValueMetaProvider {
  KeyValueMetaProvider({@required this.dbProvider, this.table = 'kvpmeta'})
      : assert(dbProvider != null) {
    createTable = '''
        CREATE TABLE $table ( 
          id integer primary key autoincrement, 
          key text UNIQUE not null,
          value text,
          meta text);
        CREATE UNIQUE INDEX idx_${table}_id ON $table (id);
        CREATE UNIQUE INDEX idx_${table}_key ON $table (key);
        CREATE UNIQUE INDEX idx_${table}_meta ON $table (meta);
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

      var sql = 'PRAGMA case_sensitive_like = true';

      await dbProvider.db.execute(sql);

      return true;
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
      return false;
    }
  }

  /// Get all the key/value pairs stored in the table. It is important
  /// to notice that if more [KeyValueMetaProvider] share the same table
  /// (by default is set to 'kvpmeta'), this method will get the ones created
  /// with other providers. To avoid this behavior, use the `table` parameter
  /// to specify a different table.
  Future<List<KeyValueMeta>> getAll() async {
    final query = 'SELECT * FROM $table';

    List<KeyValueMeta> pairs = [];

    final result = await dbProvider.db.rawQuery(query);
    if (result.isNotEmpty) {
      for (var r in result) {
        pairs.add(KeyValueMeta.fromMap(r));
      }
    }

    return pairs;
  }

  Future<KeyValueMeta> getKeyValueMeta(KeyValueMeta kvp) async {
    assert(kvp != null && kvp.id != null);

    KeyValueMeta dbKey;
    final query = 'SELECT * FROM $table WHERE id = ?';

    try {
      final result = await dbProvider.db.rawQuery(query, [kvp.id]);
      if (result.isNotEmpty) {
        dbKey = KeyValueMeta.fromMap(result.first);
      }
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
    }

    return dbKey;
  }

  Future<KeyValueMeta> getById(int id) async {
    assert(id != null);

    KeyValueMeta dbKey;
    final query = 'SELECT * FROM $table WHERE id = ?';

    try {
      final result = await dbProvider.db.rawQuery(query, [id]);
      if (result.isNotEmpty) {
        dbKey = KeyValueMeta.fromMap(result.first);
      }
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
    }

    return dbKey;
  }

  Future<List<KeyValueMeta>> getByMeta(String meta) async {
    final query = 'SELECT * FROM $table WHERE meta = \'$meta\' ';

    List<KeyValueMeta> pairs = [];

    final result = await dbProvider.db.rawQuery(query);
    if (result.isNotEmpty) {
      for (var r in result) {
        pairs.add(KeyValueMeta.fromMap(r));
      }
    }

    return pairs;
  }

  Future<KeyValueMeta> getByKey(String key) async {
    assert(key != null);

    KeyValueMeta dbKey;
    final query = 'SELECT * FROM $table WHERE key = ?';

    try {
      final result = await dbProvider.db.rawQuery(query, [key]);
      if (result.isNotEmpty) {
        dbKey = KeyValueMeta.fromMap(result.first);
      }
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
    }

    return dbKey;
  }

  Future<KeyValueMeta> insert(KeyValueMeta kvp) async {
    assert(kvp.key != null);

    try {
      await dbProvider.db.insert(table, kvp.toMap());
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
    }

    return kvp;
  }

  Future<bool> insertKeyValueMeta(String key, String value, String meta) async {
    assert(key != null);

    try {
      await dbProvider.db.execute('''
        INSERT INTO $table (key, value, meta) 
        VALUES  (?, ?, ?); 
        ''', [key, value, meta]);
      return true;
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
    }

    return false;
  }

  Future<int> update(KeyValueMeta kvp, String value) async {
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

  Future<int> updateMeta(String key, String newMeta) async {
    try {
      final query = 'UPDATE $table SET meta = ? WHERE key = ?';
      return await dbProvider.db.rawUpdate(query, [newMeta, key]);
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
      return -1;
    }
  }

  Future<int> delete(KeyValueMeta kvp) async {
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

  Future<void> bulkInsert(List<KeyValueMeta> kvps) async {
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

  Future<void> bulkDelete(List<KeyValueMeta> kvps) async {
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

  Future<void> bulkDeleteKeysStartWith(String prefixKeys) async {
    String sql = 'DELETE FROM $table WHERE key LIKE ?;';
    String prefix = '$prefixKeys%';

    try {
      await dbProvider.db.execute(sql, [prefix]);
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
    }
  }

  Future<int> bulkUpdateMeta(String meta, String newMeta) async {
    try {
      final query = 'UPDATE $table SET meta = ? WHERE meta = ?';
      return await dbProvider.db.rawUpdate(query, [newMeta, meta]);
    } catch (e) {
      print(e);
      dbProvider.logs.add(e);
      return -1;
    }
  }

  Future<void> bulkUpdate(List<KeyValueMeta> kvps) async {
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

  /// To delete all the records in the table. It is important to notice
  /// that if more provider used the same table (set by defalt to 'kvpmeta')
  /// this method will delete even the key/value pairs created with the other
  /// providers. To avoid this behavior, initialize the [KeyValueMetaProvider]
  /// giving to the `table` parameter a different value for each provider.
  Future<int> truncate() async => await dbProvider.truncate(table);
}
