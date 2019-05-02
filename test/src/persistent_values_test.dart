// Read this thread for more info about testing sqflite:
// https://github.com/tekartik/sqflite/issues/83
//
// For testing use 'flutter run .\test\src\persistent_values_test.dart'.

import 'package:test/test.dart';

import 'package:frideos_kvprx/src/dbprovider.dart';
import 'package:frideos_kvprx/src/keyvalue_provider.dart';
import 'package:frideos_kvprx/src/persistent_values.dart';

void main() {
  test('PersistentInteger', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final persistentInteger = PersistentInteger(
        persistentKey: 'integerKey', initialData: 99, table: 'kvp');
    await persistentInteger.init(dbProvider: dbProvider);

    final keyValueProvider =
        KeyValueProvider(dbProvider: dbProvider, table: 'kvp');
    await keyValueProvider.init();

    expect(persistentInteger.value, 99);

    var kvp = await keyValueProvider.getByKey('integerKey');

    expect(kvp.value, '99');

    persistentInteger.value = 33;

    kvp = await keyValueProvider.getByKey('integerKey');

    expect(kvp.value, '33');

    await keyValueProvider.dbProvider.close();
    expect(keyValueProvider.dbProvider.db.isOpen, false);

    await keyValueProvider.dbProvider.deleteDatabase();
  });

  test('PersistentDouble', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final persistentDouble = PersistentDouble(
        persistentKey: 'doubleKey', initialData: 99.99, table: 'kvp');
    await persistentDouble.init(dbProvider: dbProvider);

    final keyValueProvider =
        KeyValueProvider(dbProvider: dbProvider, table: 'kvp');
    await keyValueProvider.init();

    expect(persistentDouble.value, 99.99);

    var kvp = await keyValueProvider.getByKey('doubleKey');

    expect(kvp.value, '99.99');

    persistentDouble.value = 33.33;

    kvp = await keyValueProvider.getByKey('doubleKey');

    expect(kvp.value, '33.33');

    await keyValueProvider.dbProvider.close();
    expect(keyValueProvider.dbProvider.db.isOpen, false);

    await keyValueProvider.dbProvider.deleteDatabase();
  });

  test('PersistentBoolean', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final persistentBoolean = PersistentBoolean(
        persistentKey: 'booleanKey', initialData: false, table: 'kvp');
    await persistentBoolean.init(dbProvider: dbProvider);

    final keyValueProvider =
        KeyValueProvider(dbProvider: dbProvider, table: 'kvp');
    await keyValueProvider.init();

    expect(persistentBoolean.value, false);

    var kvp = await keyValueProvider.getByKey('booleanKey');

    expect(kvp.value, 'false');

    persistentBoolean.value = true;

    kvp = await keyValueProvider.getByKey('booleanKey');

    expect(kvp.value, 'true');

    await keyValueProvider.dbProvider.close();
    expect(keyValueProvider.dbProvider.db.isOpen, false);

    await keyValueProvider.dbProvider.deleteDatabase();
  });

  test('PersistentString', () async {
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final persistentString = PersistentString(
        persistentKey: 'stringKey', initialData: 'just a string', table: 'kvp');
    await persistentString.init(dbProvider: dbProvider);

    final keyValueProvider =
        KeyValueProvider(dbProvider: dbProvider, table: 'kvp');
    await keyValueProvider.init();

    expect(persistentString.value, 'just a string');

    var kvp = await keyValueProvider.getByKey('stringKey');

    expect(kvp.value, 'just a string');

    persistentString.value = 'another one';

    kvp = await keyValueProvider.getByKey('stringKey');

    expect(kvp.value, 'another one');

    await keyValueProvider.dbProvider.close();
    expect(keyValueProvider.dbProvider.db.isOpen, false);

    await keyValueProvider.dbProvider.deleteDatabase();
  });
}
