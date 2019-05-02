import 'package:meta/meta.dart';

import 'package:frideos_core/frideos_core.dart';

import 'dbprovider.dart';
import 'keyvalue_provider.dart';
import 'models/keyvalue_model.dart';

/// This class extends the StreamedValue class of the frideos package
/// in order to take advantages of the stream, so that, every time a
/// new value is set, this is both stored in the database (if the flag
/// `continuousSave` is set to `true` ) and sent to the stream to drive
/// a `StreamBuilder` or a `ValueBuilder` to update the UI.
///
abstract class PersistentValue<T> extends StreamedValue<T> {
  PersistentValue(
      {@required this.persistentKey,
      this.table = 'kvp',
      T initialData,
      this.continuousSave = true})
      : super(initialData: initialData);

  final String table;
  final String persistentKey;

  /// This flag indicates if the new value needs to be saved on every
  /// update. If set to `false`, it is necessary to call the [save] method
  /// to store the value to the database. By default is `true`.
  final bool continuousSave;

  KeyValueProvider _kvpProvider;

  Future<void> _initialValue(KeyValue oldKvp);

  ///
  /// This method takes as a parameter an initialiazed instance of a
  /// DbProvider, initialize the [KeyValueProvider] that creates the table
  /// in which they key/value pairs are stored.
  ///
  /// The `persistentKey` parameter is used to get from the database
  /// a [KeyValue] with the given key. The result is passed to the private
  /// method `_initialValue` that checks if it is not null, otherwise
  /// insert a first key/value pair with `persistentKey` as key and
  /// `initialData` as value.
  ///
  Future<void> init({DbProvider dbProvider}) async {
    _kvpProvider = KeyValueProvider(dbProvider: dbProvider, table: table);
    await _kvpProvider.init();

    var oldKvp = await _kvpProvider.getByKey(persistentKey);
    await _initialValue(oldKvp);
  }

  /// If [continuousSave] is `true`, every time a new value is set
  /// this is stored in the database then sent to stream.
  @override
  set value(T value) {
    if (continuousSave) {
      _update(value);
    }
    super.value = value;
  }

  /// This method needs to be used whern [continuousSave] is set to `false`,
  /// to store update the value in the database.
  Future<void> save() async {
    await _update(value);
  }

  Future<int> _update(T value) async => await _kvpProvider.updateByKey(
      persistentKey, (value is! String) ? value.toString() : value);
}

///
/// The [PersistentInteger] is meant to be used to store a value of
/// type `int`.
///
/// This class extends the [PersistentValue], so that, every time a
/// new value is set, this is both stored in the database (if the flag
/// `continuousSave` is set to `true` ) and sent to the stream to drive
/// a `StreamBuilder` or a `ValueBuilder` to update the UI.
///
/// - `table` is set by default to 'kvp', so that if not specified,
/// all the instances of a [PersistentValue] derived class, will store
/// their values to the same table.
///
/// - `persistentKey` is the key associated to the [PersistentValue] derived
///  entity.
///
/// - `initialData` is used when no record is found in the database to make
/// an insert with the first key/value pair having as key the argument passed
///  to the `persistentKey` parameter and for value the argument passed to
/// the `initialData` parameter.
///
/// - `continuousSave` is set by default to `true`, so that every time to
/// the `persistentString` is given a new value, the record in the db will
/// be updated. If set to `false`, to update the record in the db, it is
/// necessary to call the `save` method.
///
class PersistentInteger extends PersistentValue<int> {
  PersistentInteger(
      {@required String persistentKey,
      String table = 'kvp',
      int initialData,
      bool continuousSave = true})
      : super(
            persistentKey: persistentKey,
            table: table,
            initialData: initialData,
            continuousSave: continuousSave);

  @override
  Future<void> _initialValue(KeyValue oldKvp) async {
    if (oldKvp != null) {
      value = int.tryParse(oldKvp.value);
    } else {
      final initialValue = initialData != null ? initialData.toString() : '';
      await _kvpProvider.insertKeyValue(persistentKey, initialValue);
    }
  }
}

///
/// The [PersistentDouble] is meant to be used to store a value of
/// type `double`.
///
/// This class extends the [PersistentValue], so that, every time a
/// new value is set, this is both stored in the database (if the flag
/// `continuousSave` is set to `true` ) and sent to the stream to drive
/// a `StreamBuilder` or a `ValueBuilder` to update the UI.
///
/// - `table` is set by default to 'kvp', so that if not specified,
/// all the instances of a [PersistentValue] derived class, will store
/// their values to the same table.
///
/// - `persistentKey` is the key associated to the [PersistentValue] derived
///  entity.
///
/// - `initialData` is used when no record is found in the database to make
/// an insert with the first key/value pair having as key the argument passed
///  to the `persistentKey` parameter and for value the argument passed to
/// the `initialData` parameter.
///
/// - `continuousSave` is set by default to `true`, so that every time to
/// the `persistentString` is given a new value, the record in the db will
/// be updated. If set to `false`, to update the record in the db, it is
/// necessary to call the `save` method.
///
class PersistentDouble extends PersistentValue<double> {
  PersistentDouble(
      {@required String persistentKey,
      String table = 'kvp',
      double initialData,
      bool continuousSave = true})
      : super(
            persistentKey: persistentKey,
            table: table,
            initialData: initialData,
            continuousSave: continuousSave);

  @override
  Future<void> _initialValue(KeyValue oldKvp) async {
    if (oldKvp != null) {
      value = double.tryParse(oldKvp.value);
    } else {
      final initialValue = initialData != null ? initialData.toString() : '';
      await _kvpProvider.insertKeyValue(persistentKey, initialValue);
    }
  }
}

///
/// The [PersistentBoolean] is meant to be used to store a value of
/// type `bool`.
///
/// This class extends the [PersistentValue], so that, every time a
/// new value is set, this is both stored in the database (if the flag
/// `continuousSave` is set to `true` ) and sent to the stream to drive
/// a `StreamBuilder` or a `ValueBuilder` to update the UI.
///
/// - `table` is set by default to 'kvp', so that if not specified,
/// all the instances of a [PersistentValue] derived class, will store
/// their values to the same table.
///
/// - `persistentKey` is the key associated to the [PersistentValue] derived
///  entity.
///
/// - `initialData` is used when no record is found in the database to make
/// an insert with the first key/value pair having as key the argument passed
///  to the `persistentKey` parameter and for value the argument passed to
/// the `initialData` parameter.
///
/// - `continuousSave` is set by default to `true`, so that every time to
/// the `persistentString` is given a new value, the record in the db will
/// be updated. If set to `false`, to update the record in the db, it is
/// necessary to call the `save` method.
///
class PersistentBoolean extends PersistentValue<bool> {
  PersistentBoolean(
      {@required String persistentKey,
      String table = 'kvp',
      bool initialData,
      bool continuousSave = true})
      : super(
            persistentKey: persistentKey,
            table: table,
            initialData: initialData,
            continuousSave: continuousSave);

  @override
  Future<void> _initialValue(KeyValue oldKvp) async {
    if (oldKvp != null) {
      value = oldKvp.value == 'true';
    } else {
      final initialValue = initialData != null ? initialData.toString() : '';
      await _kvpProvider.insertKeyValue(persistentKey, initialValue);
    }
  }
}

///
/// The [PersistentString] is meant to be used to store a value of
/// type `String`.
///
/// This class extends the [PersistentValue], so that, every time a
/// new value is set, this is both stored in the database (if the flag
/// `continuousSave` is set to `true` ) and sent to the stream to drive
/// a `StreamBuilder` or a `ValueBuilder` to update the UI.
///
/// - `table` is set by default to 'kvp', so that if not specified,
/// all the instances of a [PersistentValue] derived class, will store
/// their values to the same table.
///
/// - `persistentKey` is the key associated to the [PersistentValue] derived
///  entity.
///
/// - `initialData` is used when no record is found in the database to make
/// an insert with the first key/value pair having as key the argument passed
///  to the `persistentKey` parameter and for value the argument passed to
/// the `initialData` parameter.
///
/// - `continuousSave` is set by default to `true`, so that every time to
/// the `persistentString` is given a new value, the record in the db will
/// be updated. If set to `false`, to update the record in the db, it is
/// necessary to call the `save` method.
///
class PersistentString extends PersistentValue<String> {
  PersistentString(
      {@required String persistentKey,
      String table = 'kvp',
      String initialData,
      bool continuousSave = true})
      : super(
            persistentKey: persistentKey,
            table: table,
            initialData: initialData,
            continuousSave: continuousSave);

  @override
  Future<void> _initialValue(KeyValue oldKvp) async {
    if (oldKvp != null) {
      value = oldKvp.value;
    } else {
      final initialValue = initialData != null ? initialData : '';
      await _kvpProvider.insertKeyValue(persistentKey, initialValue);
    }
  }
}
