// Read this thread for more info about testing sqflite:
// https://github.com/tekartik/sqflite/issues/83
//
// For testing use 'flutter run .\test\src\keyvalue_provider_test.dart'.

import 'package:test/test.dart';

import 'package:frideos_kvprx/src/dbprovider.dart';
import 'package:frideos_kvprx/src/keyvalue_provider.dart';
import 'package:frideos_kvprx/src/models/keyvalue_model.dart';

void main() {
  test('KeyValueProvider init, check database, close', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueProvider(dbProvider: dbProvider);
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

    final kvpDb = KeyValueProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    final kvpTest1 = KeyValue(key: 'testKeyValue', value: 'test value');
    final kvpTest2 = KeyValue(key: 'testKeyValue2', value: 'test value2');

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
    var kvp1 = await kvpDb.getKeyValue(pairs.first);
    expect(kvp1.key, kvpTest1.key);
    expect(kvp1.value, kvpTest1.value);

    var kvp2 = await kvpDb.getKeyValue(pairs.last);
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

    final kvpDb = KeyValueProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    // INSERT
    await kvpDb.insertKeyValue('key1', 'value1');
    await kvpDb.insertKeyValue('key2', 'value2');
    await kvpDb.insertKeyValue('key3', 'value3');

    // GET ALL
    final pairs = await kvpDb.getAll();

    expect(pairs.length, 3);

    await kvpDb.dbProvider.close();
    expect(kvpDb.dbProvider.db.isOpen, false);

    await kvpDb.dbProvider.deleteDatabase();
  });

  test('Update', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    // INSERT
    await kvpDb.insert(KeyValue(key: 'testKeyValue1', value: 'test value1'));
    await kvpDb.insert(KeyValue(key: 'testKeyValue2', value: 'test value2'));

    // GET ALL
    final pairs = await kvpDb.getAll();

    var kvp1 = await kvpDb.getKeyValue(pairs.first);
    var kvp2 = await kvpDb.getKeyValue(pairs.last);

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
    kvp2 = await kvpDb.getById(pairs.last.id);
    expect(kvp2.value, newValue);

    await kvpDb.dbProvider.close();
    expect(kvpDb.dbProvider.db.isOpen, false);

    await kvpDb.dbProvider.deleteDatabase();
  });

  test('Delete', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    // INSERT
    await kvpDb.insert(KeyValue(key: 'testKeyValue1', value: 'test value1'));
    await kvpDb.insert(KeyValue(key: 'testKeyValue2', value: 'test value2'));

    // GET ALL
    final pairs = await kvpDb.getAll();

    var kvp1 = await kvpDb.getKeyValue(pairs.first);
    var kvp2 = await kvpDb.getKeyValue(pairs.last);

    // DELETE
    var oldKeyValue1 = kvp1;
    await kvpDb.delete(kvp1);
    kvp1 = await kvpDb.getKeyValue(kvp1);
    expect(kvp1, null);

    // DELETE BY ID
    await kvpDb.insert(oldKeyValue1);
    kvp1 = await kvpDb.getByKey(oldKeyValue1.key);
    await kvpDb.deleteById(kvp1.id);
    kvp1 = await kvpDb.getKeyValue(kvp1);
    expect(kvp1, null);

    // DELETE BY KEY
    await kvpDb.insert(oldKeyValue1);
    kvp1 = await kvpDb.getByKey(oldKeyValue1.key);
    await kvpDb.deleteByKey(kvp1.key);
    kvp1 = await kvpDb.getKeyValue(kvp1);
    expect(kvp1, null);

    await kvpDb.dbProvider.close();
    expect(kvpDb.dbProvider.db.isOpen, false);

    await kvpDb.dbProvider.deleteDatabase();
  });

  test('Bulk insert KeyValue', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    await kvpDb.truncate();

    final kvps = [
      KeyValue(key: 'testKeyValue1', value: 'test value1'),
      KeyValue(key: 'testKeyValue2', value: 'test value2'),
      KeyValue(key: 'testKeyValue3', value: 'test value3'),
      KeyValue(key: 'testKeyValue4', value: 'test value4'),
      KeyValue(key: 'testKeyValue5', value: 'test value5'),
      KeyValue(key: 'testKeyValue6', value: 'test value6'),
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

  test('insertMap', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    await kvpDb.truncate();

    final map = {'1': 'a', '2': 'b', '3': 'c', '4': 'd'};

    // INSERT
    await kvpDb.insertMap(map);

    // GET ALL
    final pairs = await kvpDb.getAll();

    expect(pairs.length, map.length);

    await kvpDb.dbProvider.close();
    expect(kvpDb.dbProvider.db.isOpen, false);

    await kvpDb.dbProvider.deleteDatabase();
  });

  test('Bulk insert', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    await kvpDb.truncate();

    final kvps = [
      KeyValue(key: 'testKeyValue1', value: 'test value1'),
      KeyValue(key: 'testKeyValue2', value: 'test value2'),
      KeyValue(key: 'testKeyValue3', value: 'test value3'),
      KeyValue(key: 'testKeyValue4', value: 'test value4'),
      KeyValue(key: 'testKeyValue5', value: 'test value5'),
      KeyValue(key: 'testKeyValue6', value: 'test value6'),
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

  test('Bulk update', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    await kvpDb.truncate();

    final kvps = [
      KeyValue(key: 'testKeyValue1', value: 'test value1'),
      KeyValue(key: 'testKeyValue2', value: 'test value2'),
      KeyValue(key: 'testKeyValue3', value: 'test value3'),
      KeyValue(key: 'testKeyValue4', value: 'test value4'),
      KeyValue(key: 'testKeyValue5', value: 'test value5'),
      KeyValue(key: 'testKeyValue6', value: 'test value6'),
    ];

    // INSERT
    await kvpDb.bulkInsert(kvps);

    // GET ALL
    var pairs = await kvpDb.getAll();
    expect(pairs.length, 6);

    // Change the value of each kvp
    var updatedKvps = List<KeyValue>();
    pairs.forEach((p) => updatedKvps
        .add(KeyValue(key: p.key, value: 'newValue ${pairs.indexOf(p)}')));

    // UPDATE
    await kvpDb.bulkUpdate(updatedKvps);

    // GET ALL
    var newPairs = await kvpDb.getAll();

    expect(newPairs[0].value == pairs[0].value, false);
    expect(newPairs[0].value == updatedKvps[0].value, true);

    await kvpDb.dbProvider.close();
    expect(kvpDb.dbProvider.db.isOpen, false);

    await kvpDb.dbProvider.deleteDatabase();
  });

  test('Bulk delete', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();

    await kvpDb.truncate();

    final kvps = [
      KeyValue(key: 'testKeyValue1', value: 'test value1'),
      KeyValue(key: 'testKeyValue2', value: 'test value2'),
      KeyValue(key: 'testKeyValue3', value: 'test value3'),
      KeyValue(key: 'testKeyValue4', value: 'test value4'),
      KeyValue(key: 'testKeyValue5', value: 'test value5'),
      KeyValue(key: 'testKeyValue6', value: 'test value6'),
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
