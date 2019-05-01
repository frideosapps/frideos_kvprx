// Read this thread for more info about testing sqflite:
// https://github.com/tekartik/sqflite/issues/83
//
// For testing use 'flutter run .\test\src\dbprovider_test.dart'.

import 'package:test/test.dart';
import 'package:frideos_kvprx/src/dbprovider.dart';

const databaseName = 'test.db';
const createTable = '''
    create table test ( 
          id integer primary key autoincrement, 
          key text UNIQUE not null,
          value text)
        ''';
const insertData = '''
        INSERT INTO test (key, value) 
        VALUES  (?, ?); 
        ''';

void main() {
  test('Open, create a table, close, and delete a database', () async {
    final dbprovider = DbProvider(databaseName: databaseName);
    var init = await dbprovider.init();

    expect(init, true);
    expect(dbprovider.db.isOpen, true);

    await dbprovider.close();
    expect(dbprovider.db.isOpen, false);

    await dbprovider.deleteDatabase();

    var exists = await dbprovider.checkDatabaseExists();

    await expect(exists, false);
  });
  test('Truncate', () async {
    final dbprovider = DbProvider(databaseName: 'test.db');

    var init = await dbprovider.init();

    // CREATE TABLE AND INSERT SOME DATA
    await dbprovider.db.transaction((txn) async {
      await txn.execute(createTable);

      await txn.execute(insertData, ['testKey', 'test value']);
    });

    List<Map<String, dynamic>> result;

    // GET ALL
    await dbprovider.db.transaction((txn) async {
      result = await txn.rawQuery('SELECT * FROM test');
    });

    expect(result.isNotEmpty, true);

    // TRUNCATE
    await dbprovider.truncate('test');

    // CHECK IF THE TABLE IS EMPTY
    await dbprovider.db.transaction((txn) async {
      result = await txn.rawQuery('SELECT * FROM test');
    });

    expect(result.isEmpty, true);

    await dbprovider.deleteDatabase();

    var exists = await dbprovider.checkDatabaseExists();

    await expect(exists, false);
  });
}
