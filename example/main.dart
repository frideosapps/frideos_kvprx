import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:frideos_core/frideos_core.dart';

import 'package:frideos_kvprx/frideos_kvprx.dart';

const style = TextStyle(fontWeight: FontWeight.w500);

// Key for the first key/value pair
const kvp1Key = 'key1';

// Key for the second key/value pair
const kvp2Key = 'key2';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frideos KvpRx demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Initialize the DbProvider. This will create a connection to a
  // database stored in a file named 'example.db'.
  final dbProvider = DbProvider(databaseName: 'example.db');

  // Declare a KeyValueProvider to handle all the key/value
  // pairs stored in the database.
  KeyValueProvider kvp1;

  // Another KeyValueProvider can be used to store key/value pairs
  // in another table of the same database (e.g. one table 'appstate'
  // to store info about the appstate and another one name 'users' or
  // 'products' for other purposes).
  //
  // It is important to notice that by default the table is set to 'kvp'.
  // So, it is necessary to use the parameter `table` on the second provider
  // in order to not share the same table.
  KeyValueProvider kvp2;

  // These two StreamedValue are used to update the UI with the
  // value of the key/value pairs stored in the database.
  final keyValue1 = StreamedValue<KeyValue>();
  final keyValue2 = StreamedValue<KeyValue>();

  // A persistentString is used to store a kvp with a value of type String.
  // If provided, the `initialData` parameter is used to make the first insert
  // in the db if no value associated with the given `persistentKey` is found.
  //
  // It is important to notice the in this example all the persistentValues
  // share the same table 'kvprx'. It could be possible create a
  // KeyValueProvider and initialize it with the `table` parameters set to
  // 'kvprx' in order to handle these key/value/pairs (e.g. get all the
  // key/value pairs stored).
  final persistentString = PersistentString(
      table: 'kvprx',
      persistentKey: 'persistentValueString',
      initialData: 'ABCDEFGHIJKLMNOPRQSTUVWXY',
      continuousSave: true);

  final persistentBoolean = PersistentBoolean(
      table: 'kvprx', persistentKey: 'persistentBoolean', initialData: true);

  final persistentInteger = PersistentInteger(
      table: 'kvprx', persistentKey: 'persistentInteger', initialData: 10);

  final persistentDouble = PersistentDouble(
      table: 'kvprx',
      persistentKey: 'persistentValueDouble',
      initialData: 12.44);

  Future<void> init() async {
    // Uncomment to delete the database.
    // await dbProvider.deleteDatabase();

    // Step 1: DbProvider instance initialization.
    await dbProvider.init();

    // Step 2: PersistentValue / KeyValueProvider initialization.
    await persistentString.init(dbProvider: dbProvider);
    await persistentBoolean.init(dbProvider: dbProvider);
    await persistentInteger.init(dbProvider: dbProvider);
    await persistentDouble.init(dbProvider: dbProvider);

    // If a second table is needed to the second KeyValueProvider
    // the `table` parameter will be different.
    kvp1 = KeyValueProvider(dbProvider: dbProvider, table: 'kvp');
    kvp2 = KeyValueProvider(dbProvider: dbProvider, table: 'kvp2');

    await kvp1.init();
    await kvp2.init();

    // Cheking if already exists
    var result = await kvp1.getByKey(kvp1Key);
    if (result == null) {
      // Insert the first kvp
      var toAdd = KeyValue(key: kvp1Key, value: 'ABCDEFGHIJKLMNOPRQSTUVWXY');
      await kvp1.insert(toAdd);

      // get the kvp inserted by using its key (in this case this is step
      // is redundant because we could just use the `toAdd.value`)
      keyValue1.value = await kvp1.getByKey(kvp1Key);
    } else {
      // A record is already present in the database, then send to stream its value
      // and update the UI.
      keyValue1.value = result;
    }

    // INSERT by insertKeyValue
    result = await kvp2.getByKey(kvp2Key);
    if (result == null) {
      await kvp2.insertKeyValue(kvp2Key, 'ABCDEFGHIJKLMNOPRQSTUVWXY');
      keyValue2.value = await kvp2.getByKey(kvp2Key);
    } else {
      keyValue2.value = result;
    }
  }

  Future<void> updateRx() async {
    var rand = math.Random();
    var nextChar = persistentString.value[rand.nextInt(25)];

    // Every time a new value is set, the record in the database
    // is updated. To avoid this behavior set to `false` the
    // `continuousSave` in PersistentValue derived objects initialization
    // and call the `save` method to update the record in the database
    // whenever you need.
    persistentString.value += nextChar;
    persistentBoolean.value = !persistentBoolean.value;
    persistentDouble.value += 0.51;
    persistentInteger.value += 2;
  }

  Future<void> updateValues() async {
    var rand = math.Random();

    // Update KeyValue
    var oldValue = keyValue1.value.value;
    var nextChar = oldValue[rand.nextInt(25)];
    await kvp1.update(keyValue1.value, oldValue + nextChar);

    // Redundant step, only to show how to get kvp by id. In a normal case
    // you would assign to keyValue1.value the same value used to update
    // the record ('oldValue + nextChar') to avoid an unnecessary query.
    keyValue1.value = await kvp1.getById(keyValue1.value.id);

    // Update by key
    var oldValue2 = keyValue1.value.value;
    nextChar = oldValue2[rand.nextInt(25)];
    await kvp2.updateByKey(kvp2Key, oldValue2 + nextChar);
    keyValue2.value = await kvp2.getByKey(keyValue2
        .value.key); // Redundant step, only to show how to get a kvp by key.
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    dbProvider.close();
    keyValue1.dispose();
    keyValue2.dispose();
    persistentString.dispose();
    persistentBoolean.dispose();
    persistentDouble.dispose();
    persistentInteger.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Frideos KvpRx demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // As an alternative, you could use the ValueBuilder widget
            // of the frideos package:
            //
            // ValueBuilder<bool>(
            //    streamed: persistentBoolean
            //
            StreamBuilder<bool>(
                stream: persistentBoolean.outStream,
                builder: (context, snapshot) {
                  return !snapshot.hasData
                      ? Container()
                      : Column(
                          children: <Widget>[
                            const Text('PersistentBoolean:', style: style),
                            Text(
                              '${snapshot.data}',
                            ),
                            Divider(),
                          ],
                        );
                }),
            // ValueBuilder<int>(
            //    streamed: persistentInteger
            //
            StreamBuilder<int>(
                stream: persistentInteger.outStream,
                builder: (context, snapshot) {
                  return !snapshot.hasData
                      ? Container()
                      : Column(
                          children: <Widget>[
                            const Text('PersistentInteger:', style: style),
                            Text(
                              snapshot.data.toString(),
                            ),
                            Divider(),
                          ],
                        );
                }),
            // ValueBuilder<double>(
            //    streamed: persistentDouble
            //
            StreamBuilder<double>(
                stream: persistentDouble.outStream,
                builder: (context, snapshot) {
                  return !snapshot.hasData
                      ? Container()
                      : Column(
                          children: <Widget>[
                            const Text('PersistentDouble:', style: style),
                            Text(
                              '${snapshot.data.toStringAsFixed(2)}',
                            ),
                            Divider(),
                          ],
                        );
                }),
            // ValueBuilder<String>(
            //    streamed: persistentString
            //
            StreamBuilder<String>(
                stream: persistentString.outStream,
                builder: (context, snapshot) {
                  return !snapshot.hasData
                      ? Container()
                      : Column(
                          children: <Widget>[
                            const Text('PersistentString:', style: style),
                            Text(
                              '${snapshot.data}',
                            ),
                            Divider(),
                          ],
                        );
                }),
            // ValueBuilder<KeyValue>(
            //    streamed: keyValue1
            //
            StreamBuilder<KeyValue>(
                stream: keyValue1.outStream,
                builder: (context, snapshot) {
                  return !snapshot.hasData
                      ? Container()
                      : Column(
                          children: <Widget>[
                            const Text('KeyValue 1:', style: style),
                            Text(
                              snapshot.data.value,
                            ),
                            Divider(),
                          ],
                        );
                }),
            // ValueBuilder<KeyValue>(
            //    streamed: keyValue2
            //
            StreamBuilder<KeyValue>(
                stream: keyValue2.outStream,
                builder: (context, snapshot) {
                  return !snapshot.hasData
                      ? Container()
                      : Column(
                          children: <Widget>[
                            const Text('KeyValue 2:', style: style),
                            Text(
                              snapshot.data.value,
                            ),
                          ],
                        );
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  onPressed: updateRx,
                  child: const Text('Update KvpRxs',
                      style: TextStyle(color: Colors.white)),
                  color: Colors.blue,
                ),
                RaisedButton(
                  onPressed: updateValues,
                  child: const Text('Update key values',
                      style: TextStyle(color: Colors.white)),
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
