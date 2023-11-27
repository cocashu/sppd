import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OfflineDatabase {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database == null) {
      _database = await openDatabase(
        join(await getDatabasesPath(), 'my_database.db'),
        version: 1,
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE IF NOT EXISTS goods (id INTEGER PRIMARY KEY, goodscode TEXT, goodsname TEXT, BaseBarCode TEXT)',
          );
        },
      );
    }
    return _database!;
  }

  static Future<void> insertData(Map<String, dynamic> data) async {
    Database database = await getDatabase();
    await database.insert('goods', data);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 初始化Flutter引擎

  String jsonData =
      '{"succeed":"1","data":[{"id":"209162","goodscode":"0101011000","goodsname":"\u5a77\u5a77\u7389\u7acb\u4e45.5\u62a4\u8fb9\u7897","BaseBarCode":"6958476847091"}]}';

  // 解析JSON数据
  var parsedData = json.decode(jsonData);
  var succeed = parsedData['succeed'];
  var data = parsedData['data'];

  if (succeed == '1') {
    if (data is List && data.isNotEmpty) {
      Map<String, dynamic> firstData = data[0];
      await OfflineDatabase.insertData(firstData);
    }
  }
}
