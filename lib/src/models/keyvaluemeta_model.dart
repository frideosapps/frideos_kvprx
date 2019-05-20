import '../config.dart';

/// KeyValueMeta class
///
/// Model used to store and get key/value pairs to the database.
///
class KeyValueMeta {
  KeyValueMeta({this.key, this.value, this.meta});

  KeyValueMeta.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    key = map[columnKey];
    value = map[columnValue];
    meta = map[columnMeta];
  }

  int id;
  String key;
  String value;
  String meta;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      columnKey: key,
      columnValue: value,
      columnMeta: meta
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  @override
  String toString() {
    return 'ID: $id, Key: $key, Value: $value, Meta: $meta';
  }
}
