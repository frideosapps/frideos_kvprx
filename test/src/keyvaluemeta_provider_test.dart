// Read this thread for more info about testing sqflite:
// https://github.com/tekartik/sqflite/issues/83
//
// For testing use 'flutter run .\test\src\keyvaluemeta_provider_test.dart'.

import 'package:test/test.dart';

import 'package:frideos_kvprx/src/dbprovider.dart';
import 'package:frideos_kvprx/src/keyvaluemeta_provider.dart';
import 'package:frideos_kvprx/src/models/keyvaluemeta_model.dart';

const String table = 'kvpmeta';

void main() {
  test('KeyValueMetaProvider init, check database, close', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueMetaProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    expect(init, true);
    expect(kvpDb.dbProvider.db.isOpen, true);

    await kvpDb.dbProvider.close();
    expect(kvpDb.dbProvider.db.isOpen, false);

    await kvpDb.dbProvider.deleteDatabase();
  });

  test('Insert and get', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueMetaProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    final kvpTest1 =
        KeyValueMeta(key: 'testKeyValue', value: 'test value', meta: 'meta');
    final kvpTest2 =
        KeyValueMeta(key: 'testKeyValue2', value: 'test value2', meta: 'meta2');

    // INSERT
    await kvpDb.insert(kvpTest1);
    await kvpDb.insert(kvpTest2);

    // GET ALL
    final pairs = await kvpDb.getAll();

    expect(pairs.length, 2);
    expect(pairs.first.value, kvpTest1.value);
    expect(pairs.first.key, kvpTest1.key);
    expect(pairs.last.value, kvpTest2.value);
    expect(pairs.last.key, kvpTest2.key);

    // GET BY KVP
    var kvp1 = await kvpDb.getKeyValueMeta(pairs.first);
    expect(kvp1.key, kvpTest1.key);
    expect(kvp1.value, kvpTest1.value);

    var kvp2 = await kvpDb.getKeyValueMeta(pairs.last);
    expect(kvp2.key, kvpTest2.key);
    expect(kvp2.value, kvpTest2.value);

    // GET BY ID
    kvp1 = await kvpDb.getById(pairs.first.id);
    expect(kvp1.key, kvpTest1.key);
    expect(kvp1.value, kvpTest1.value);

    kvp2 = await kvpDb.getById(pairs.last.id);
    expect(kvp2.key, kvpTest2.key);
    expect(kvp2.value, kvpTest2.value);

    // GET BY KEY
    kvp1 = await kvpDb.getByKey(pairs.first.key);
    expect(kvp1.key, kvpTest1.key);
    expect(kvp1.value, kvpTest1.value);

    kvp2 = await kvpDb.getByKey(pairs.last.key);
    expect(kvp2.key, kvpTest2.key);
    expect(kvp2.value, kvpTest2.value);

    await kvpDb.dbProvider.close();
    expect(kvpDb.dbProvider.db.isOpen, false);

    await kvpDb.dbProvider.deleteDatabase();
  });

  test('insertKeyValue', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueMetaProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    // INSERT
    await kvpDb.insertKeyValueMeta('key1', 'value1', 'meta1');
    await kvpDb.insertKeyValueMeta('key2', 'value2', 'meta1');
    await kvpDb.insertKeyValueMeta('key3', 'value3', 'meta1');
    await kvpDb.insertKeyValueMeta('key4', 'value1', 'meta2');
    await kvpDb.insertKeyValueMeta('key5', 'value2', 'meta2');
    await kvpDb.insertKeyValueMeta('key6', 'value3', 'meta2');

    // GET ALL
    final pairs = await kvpDb.getAll();

    expect(pairs.length, 6);

    await kvpDb.dbProvider.close();
    expect(kvpDb.dbProvider.db.isOpen, false);

    await kvpDb.dbProvider.deleteDatabase();
  });

  test('getByMeta', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueMetaProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    // INSERT
    await kvpDb.insertKeyValueMeta('key1', 'value1', 'meta1');
    await kvpDb.insertKeyValueMeta('key2', 'value2', 'meta1');
    await kvpDb.insertKeyValueMeta('key3', 'value3', 'meta1');
    await kvpDb.insertKeyValueMeta('key4', 'value1', 'meta2');
    await kvpDb.insertKeyValueMeta('key5', 'value2', 'meta2');
    await kvpDb.insertKeyValueMeta('key6', 'value3', 'meta2');

    // GET ALL
    final pairs = await kvpDb.getByMeta('meta2');

    expect(pairs.length, 3);

    await kvpDb.dbProvider.close();
    expect(kvpDb.dbProvider.db.isOpen, false);

    await kvpDb.dbProvider.deleteDatabase();
  });

  test('Update', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueMetaProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    // INSERT
    await kvpDb
        .insert(KeyValueMeta(key: 'testKeyValue1', value: 'test value1'));
    await kvpDb
        .insert(KeyValueMeta(key: 'testKeyValue2', value: 'test value2'));

    // GET ALL
    final pairs = await kvpDb.getAll();

    var kvp1 = await kvpDb.getKeyValueMeta(pairs.first);
    var kvp2 = await kvpDb.getKeyValueMeta(pairs.last);

    // UPDATE
    var newValue = 'new value';
    await kvpDb.update(kvp1, newValue);
    kvp1 = await kvpDb.getByKey(kvp1.key);
    expect(kvp1.value, newValue);

    // UPDATE BY ID
    newValue = 'new value2';
    await kvpDb.updateById(kvp2.id, newValue);
    kvp2 = await kvpDb.getById(pairs.last.id);
    expect(kvp2.value, newValue);

    // UPDATE BY KEY
    newValue = 'new value3';
    await kvpDb.updateByKey(kvp2.key, newValue);
    kvp2 = await kvpDb.getByKey(pairs.last.key);
    expect(kvp2.value, newValue);

    await kvpDb.dbProvider.close();
    expect(kvpDb.dbProvider.db.isOpen, false);

    await kvpDb.dbProvider.deleteDatabase();
  });

  test('updateMeta', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueMetaProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    // INSERT
    final key = 'key1';
    final value = 'value1';
    var meta = 'meta1';
    await kvpDb.insertKeyValueMeta(key, value, meta);

    // GET ALL
    var kvp = await kvpDb.getByKey(key);
    expect(kvp.value, value);

    meta = 'meta2';
    await kvpDb.updateMeta(key, meta);

    kvp = await kvpDb.getByKey(key);
    expect(kvp.meta, meta);

    await kvpDb.dbProvider.close();
    expect(kvpDb.dbProvider.db.isOpen, false);

    await kvpDb.dbProvider.deleteDatabase();
  });

  test('bulkUpdateMeta', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueMetaProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    // INSERT
    await kvpDb.insertKeyValueMeta('key1', 'value1', 'meta1');
    await kvpDb.insertKeyValueMeta('key2', 'value2', 'meta1');
    await kvpDb.insertKeyValueMeta('key3', 'value3', 'meta1');
    await kvpDb.insertKeyValueMeta('key4', 'value1', 'meta2');
    await kvpDb.insertKeyValueMeta('key5', 'value2', 'meta2');
    await kvpDb.insertKeyValueMeta('key6', 'value3', 'meta2');

    // GET ALL
    var pairs = await kvpDb.getByMeta('meta1');
    expect(pairs.length, 3);

    await kvpDb.bulkUpdateMeta('meta2', 'meta1');

    pairs = await kvpDb.getByMeta('meta1');
    expect(pairs.length, 6);

    await kvpDb.dbProvider.close();
    expect(kvpDb.dbProvider.db.isOpen, false);

    await kvpDb.dbProvider.deleteDatabase();
  });

  test('Delete', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueMetaProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    // INSERT
    await kvpDb
        .insert(KeyValueMeta(key: 'testKeyValue1', value: 'test value1'));
    await kvpDb
        .insert(KeyValueMeta(key: 'testKeyValue2', value: 'test value2'));

    // GET ALL
    final pairs = await kvpDb.getAll();

    var kvp1 = await kvpDb.getKeyValueMeta(pairs.first);
    var kvp2 = await kvpDb.getKeyValueMeta(pairs.last);

    // DELETE
    var oldKeyValue1 = kvp1;
    await kvpDb.delete(kvp1);
    kvp1 = await kvpDb.getKeyValueMeta(kvp1);
    expect(kvp1, null);

    // DELETE BY ID
    await kvpDb.insert(oldKeyValue1);
    kvp1 = await kvpDb.getByKey(oldKeyValue1.key);
    await kvpDb.deleteById(kvp1.id);
    kvp1 = await kvpDb.getKeyValueMeta(kvp1);
    expect(kvp1, null);

    // DELETE BY KEY
    await kvpDb.insert(oldKeyValue1);
    kvp1 = await kvpDb.getByKey(oldKeyValue1.key);
    await kvpDb.deleteByKey(kvp1.key);
    kvp1 = await kvpDb.getKeyValueMeta(kvp1);
    expect(kvp1, null);

    await kvpDb.dbProvider.close();
    expect(kvpDb.dbProvider.db.isOpen, false);

    await kvpDb.dbProvider.deleteDatabase();
  });

  test('Bulk insert KeyValueMeta', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueMetaProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    await kvpDb.truncate();

    final kvps = [
      KeyValueMeta(key: 'testKeyValue1', value: 'test value1', meta: 'meta1'),
      KeyValueMeta(key: 'testKeyValue2', value: 'test value2', meta: 'meta2'),
      KeyValueMeta(key: 'testKeyValue3', value: 'test value3', meta: 'meta3'),
      KeyValueMeta(key: 'testKeyValue4', value: 'test value4', meta: 'meta4'),
      KeyValueMeta(key: 'testKeyValue5', value: 'test value5', meta: 'meta5'),
      KeyValueMeta(key: 'testKeyValue6', value: 'test value6', meta: 'meta6'),
    ];

    // INSERT
    await kvpDb.bulkInsert(kvps);

    // GET ALL
    final pairs = await kvpDb.getAll();

    expect(pairs.length, 6);

    await kvpDb.dbProvider.close();
    expect(kvpDb.dbProvider.db.isOpen, false);

    await kvpDb.dbProvider.deleteDatabase();
  });

  test('Bulk delete KeyValueMeta', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueMetaProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    await kvpDb.truncate();

    final kvps = [
      KeyValueMeta(key: 'testKeyValue1', value: 'test value1', meta: 'meta1'),
      KeyValueMeta(key: 'testKeyValue2', value: 'test value2', meta: 'meta2'),
      KeyValueMeta(key: 'testKeyValue3', value: 'test value3', meta: 'meta3'),
      KeyValueMeta(key: 'testKeyValue4', value: 'test value4', meta: 'meta4'),
      KeyValueMeta(key: 'testKeyValue5', value: 'test value5', meta: 'meta5'),
      KeyValueMeta(key: 'testKeyValue6', value: 'test value6', meta: 'meta6'),
    ];

    // INSERT
    await kvpDb.bulkInsert(kvps);

    // GET ALL
    var pairs = await kvpDb.getAll();

    expect(pairs.length, 6);

    // Bulk delete (2 out of 6)
    await kvpDb.bulkDelete(pairs.sublist(0, 2));

    // GET ALL
    pairs = await kvpDb.getAll();
    expect(pairs.length, 4);

    await kvpDb.dbProvider.close();
    expect(kvpDb.dbProvider.db.isOpen, false);

    await kvpDb.dbProvider.deleteDatabase();
  });

  test('Bulk delete Keys', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueMetaProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    await kvpDb.truncate();

    final kvps = [
      KeyValueMeta(key: 'testKeyValue1', value: 'test value1'),
      KeyValueMeta(key: 'testKeyValue2', value: 'test value2'),
      KeyValueMeta(key: 'testKeyValue3', value: 'test value3'),
      KeyValueMeta(key: 'testKeyValue4', value: 'test value4'),
      KeyValueMeta(key: 'testKeyValue5', value: 'test value5'),
      KeyValueMeta(key: 'testKeyValue6', value: 'test value6'),
    ];

    // INSERT
    await kvpDb.bulkInsert(kvps);

    // GET ALL
    var pairs = await kvpDb.getAll();

    expect(pairs.length, 6);

    // Bulk delete (3 out of 6)
    await kvpDb
        .bulkDeleteKeys(['testKeyValue3', 'testKeyValue4', 'testKeyValue5']);

    // GET ALL
    pairs = await kvpDb.getAll();
    expect(pairs.length, 3);

    await kvpDb.dbProvider.close();
    expect(kvpDb.dbProvider.db.isOpen, false);

    await kvpDb.dbProvider.deleteDatabase();
  });
}
