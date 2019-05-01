import 'package:meta/meta.dart';

import 'package:frideos_core/frideos_core.dart';

import 'dbprovider.dart';
import 'keyvalue_provider.dart';
import 'models/keyvalue_model.dart';

abstract class PersistentValue<T> extends StreamedValue<T> {
  PersistentValue(
      {@required this.persistentKey,
      this.table = 'kvp',
      T initialData,
      this.continuousSave = true})
      : super(initialData: initialData);

  final String table;
  final String persistentKey;
  final bool continuousSave;

  KeyValueProvider _kvpProvider;

  Future<void> _initialValue(KeyValue oldKvp);

  Future<void> init({DbProvider dbProvider}) async {
    _kvpProvider = KeyValueProvider(dbProvider: dbProvider, table: table);
    await _kvpProvider.init();

    var oldKvp = await _kvpProvider.getByKey(persistentKey);
    await _initialValue(oldKvp);
  }

  @override
  set value(T value) {
    if (continuousSave) {
      _update(value);
    }
    super.value = value;
  }

  Future<void> save() async {
    await _update(value);
  }

  Future<int> _update(T value) async => await _kvpProvider.updateByKey(
      persistentKey, (value is! String) ? value.toString() : value);
}

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
