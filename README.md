# frideos_kvprx [![pub package](https://img.shields.io/pub/v/frideos_kvprx.svg)](https://pub.dartlang.org/packages/frideos_kvprx)

**frideos_kvprx** is a library that offers persistent and reactive classes, and helpers to easily store key/value pairs in the database, using the sqflite plugin.

- **DbProvider** : class used to inizialize the database.
- **KeyValue** : class to handle a key/value pair.
- **KeyValueProvider** : class with methods to get, insert, update, delete the key/value pairs stored in the db.
- **PersistentValue and derived classes** : classes derived from the `StreamedValue` class of the [frideos_core](https://pub.dartlang.org/packages/frideos_core) package to make a key/value pair persistent and reactive using streams. Used along with the `StreamBuilder` or the  `ValueBuilder` widget of the [frideos](https://pub.dartlang.org/packages/frideos) package, make it possible to update the UI with the last value on the stream and save the value to the database every time a new value is set.


## DbProvider

### Initialization
```dart
// Initialize a database.
// By default the database name is set to 'appdb.db'.
final dbProvider = DbProvider(databaseName: 'test.db');

// Init the dabase
await dbProvider.init();  
```

### Close the connection
```dart
await dbProvider.close();  
```

### Delete the current database
```dart
await dbProvider.deleteDatabase();
```

### Truncate a table of the database
```dart
await dbProvider.truncate('tableName');
```



## KeyValueProvider


#### Initialization
```dart
    final dbProvider = DbProvider(databaseName: 'test.db');
    await dbProvider.init();

    final kvpDb = KeyValueProvider(dbProvider: dbProvider);
    var init = await kvpDb.init();
```

### INSERT

#### - Insert by insert method
```dart
    final kvpTest1 = KeyValue(key: 'testKeyValue', value: 'test value');
    final kvpTest2 = KeyValue(key: 'testKeyValue2', value: 'test value2');

    // INSERT
    await kvpDb.insert(kvpTest1);
    await kvpDb.insert(kvpTest2);
```

#### - Insert by insertKeyValue method

```dart
    await kvpDb.insertKeyValue('key', 'value')
```

#### - Bulk insert


```dart
 final kvps = [
      KeyValue(key: 'testKeyValue1', value: 'test value1'),
      KeyValue(key: 'testKeyValue2', value: 'test value2'),
      KeyValue(key: 'testKeyValue3', value: 'test value3'),
      KeyValue(key: 'testKeyValue4', value: 'test value4'),
      KeyValue(key: 'testKeyValue5', value: 'test value5'),
      KeyValue(key: 'testKeyValue6', value: 'test value6'),
    ];

  await kvpDb.bulkInsert(kvps);  
```


#### - Insert a map

```dart
final map = {'1': 'a', '2': 'b', '3': 'c', '4': 'd'};

// INSERT
await kvpDb.insertMap(map);
```

### GET

#### - Get all key/value pairs
```dart
    // GET ALL
    final pairs = await kvpDb.getAll();
```

#### - Get single kvp by getKeyValue method
```dart
final kvpTest1 = KeyValue(key: 'testKeyValue', value: 'test value');
var kvp1 = await kvpDb.getKeyValue(kvpTest1);
```

#### - Get single kvp by getById method
```dart
var kvp1 = await kvpDb.getById(id);
```

#### - Get single kvp by getByKey method
```dart
var kvp1 = await kvpDb.getByKey('key');
```

### UPDATE

#### - Update single kvp by update method
```dart
var kvp1 = await kvpDb.getByKey('key');
await kvpDb.update(kvp1, 'newValue');
```
#### - Update single kvp by updateById method
```dart
await kvpDb.updateById(id, 'newValue');
```
#### - Update single kvp by updateByKey method
```dart
await kvpDb.updateByKey('key', 'newValue');
```

#### - Bulk update
```dart

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
    
    // Change the value of each kvp
    var updatedKvps = List<KeyValue>();
    pairs.forEach((p) => updatedKvps
        .add(KeyValue(key: p.key, value: 'newValue ${pairs.indexOf(p)}')));

    // UPDATE
    await kvpDb.bulkUpdate(updatedKvps);
```


### DELETE

#### - Delete single kvp by delete method
```dart
var kvp1 = await kvpDb.getByKey('key');
await kvpDb.delete(kvp1);
```
#### - Delete single kvp by deleteById method
```dart
await kvpDb.deleteById(id);
```
#### - Delete single kvp by deleteByKey method
```dart
await kvpDb.deleteByKey('key');
```
#### - Bulk delete 
```dart
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

// Bulk delete (3 out of 6)
await kvpDb.bulkDeleteKeys(['testKeyValue3', 'testKeyValue4','testKeyValue5']);
```

### TRUNCATE

Method used to delete all the records in the table.

```dart
await kvpDb.truncate();
```

## PersistentValues

#### - PersistentString
#### - PersistentBoolean
#### - PersistentInt
#### - PersistentDouble

### Usage:

#### 1 - Declare an instance of a `PersistentValue` derived object

- `table` is set by default to 'kvprx', so that if not specified,
all the instances of a `PersistentValue` derived class, will store their values to the same table. 


- `persistentKey` is the key associated to the `PersistentValue` derived entity.

- `initialData` is used when no record is found in the database to make an insert with the first key/value pair having as key the argument passed to the `persistentKey` parameter and for value the argument passed to the `initialData` parameter. 

- `continuousSave` is set by default to `true`, so that every time to the `persistentString` is given a new value, the record in the db will be updated. If set to `false`, to update the record in the db, it is necessary to call the `save` method.


```dart    
  final persistentString = PersistentString(
      table: 'kvprx',      
      persistentKey: 'persistentValueString',
      initialData: 'ABCDEFGHIJKLMNOPRQSTUVWXY',
      continuousSave: true);
```
#### 2 - Initialization
```dart
// Initialize the dbProvider
await dbProvider.init();

// Call the init method of the `PersistentString` class to initialize
// the KeyValueProvider, check if a record is already present in the db
// and set it as the current value. If no record is found, the argument passed
// to the `initialData` parameters is used to insert a new record in the db.
await persistentString.init(dbProvider: dbProvider);
```


#### 3 - Change the value
```dart
// Every time a new value is set, this will be sent to stream and stored 
// in the database.
persistentString.value = 'New String';

// Only if `continuousSave` is set to `false` it is necessary to call
// the `save` method in order to update the record in the db.
// await persistentString.save();
```






