import '../config.dart';

/// KeyValue class
///
/// Model used to store and get key/value pairs to the database.
///
class KeyValue {
  KeyValue({this.key, this.value});

  KeyValue.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    key = map[columnKey];
    value = map[columnValue];
  }

  int id;
  String key;
  String value;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{columnKey: key, columnValue: value};
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  @override
  String toString() {
    return 'ID: $id, Key: $key, Value: $value';
  }
}
