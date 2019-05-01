import '../config.dart';

class KeyValue {
  KeyValue({this.key, this.value});

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

  KeyValue.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    key = map[columnKey];
    value = map[columnValue];
  }

  @override
  String toString() {
    return 'ID: $id, Key: $key, Value: $value';
  }
}
