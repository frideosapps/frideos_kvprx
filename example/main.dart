import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:frideos_core/frideos_core.dart';

import 'package:frideos_kvprx/frideos_kvprx.dart';

const kvp1Key = 'key1';
const kvp2Key = 'key2';
const style = TextStyle(fontWeight: FontWeight.w500);

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
  final dbProvider = DbProvider(databaseName: 'example.db');
  KeyValueProvider kvp1;
  KeyValueProvider kvp2;

  final keyValue1 = StreamedValue<KeyValue>();
  final keyValue2 = StreamedValue<KeyValue>();

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
    //await dbProvider.deleteDatabase();
    await dbProvider.init();

    await persistentString.init(dbProvider: dbProvider);
    await persistentBoolean.init(dbProvider: dbProvider);
    await persistentInteger.init(dbProvider: dbProvider);
    await persistentDouble.init(dbProvider: dbProvider);

    kvp1 = KeyValueProvider(dbProvider: dbProvider, table: 'kvp');
    kvp2 = KeyValueProvider(dbProvider: dbProvider, table: 'kvp');

    await kvp1.init();
    await kvp2.init();

    // Cheking if already exists
    var result = await kvp1.getByKey(kvp1Key);
    if (result == null) {
      var toAdd = KeyValue(key: kvp1Key, value: 'ABCDEFGHIJKLMNOPRQSTUVWXY');
      await kvp1.insert(toAdd);
      keyValue1.value = await kvp1.getByKey(kvp1Key);
    } else {
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

    persistentBoolean.value = !persistentBoolean.value;
    persistentDouble.value += 0.51;
    var nextChar = persistentString.value[rand.nextInt(25)];
    persistentString.value += nextChar;
    persistentInteger.value += 2;

    
  }

  Future<void> updateValues() async {
    var rand = math.Random();

    // Update KeyValue
    var oldValue = keyValue1.value.value;
    var nextChar = oldValue[rand.nextInt(25)];
    await kvp1.update(keyValue1.value, oldValue + nextChar);
    keyValue1.value = await kvp1.getById(keyValue1.value.id);

    // Update by key
    var oldValue2 = keyValue1.value.value;
    nextChar = oldValue2[rand.nextInt(25)];
    await kvp2.updateByKey(kvp2Key, oldValue2 + nextChar);
    keyValue2.value = await kvp2.getByKey(keyValue2.value.key);
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
    persistentBoolean.dispose();
    persistentDouble.dispose();
    persistentString.dispose();
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
