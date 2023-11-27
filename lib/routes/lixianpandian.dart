// ignore_for_file: unnecessary_this

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'lixianrequest.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart' hide Response;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_easy_permission/easy_permissions.dart';
import 'package:flutter_scankit/flutter_scankit.dart';
import '../main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:expression_language/expression_language.dart';

const _permissions = [Permissions.CAMERA];

const _permissionGroup = [PermissionGroup.Camera];

class lixian_PandianRoute extends StatefulWidget {
  const lixian_PandianRoute({Key? key}) : super(key: key);

  @override
  _lixian_PandianRouteState createState() => _lixian_PandianRouteState();
}

class _lixian_PandianRouteState extends State<lixian_PandianRoute> {
  final Controller c = Get.put(Controller());
  final FocusNode _goodscodeFocus = FocusNode();
  final FocusNode _barscodeFocus = FocusNode();
  final FocusNode _shuliangFocus = FocusNode();
  final TextEditingController _barscode =
      TextEditingController(); //声明controller
  final TextEditingController _goodscode =
      TextEditingController(); //声明controller
  final TextEditingController _goodsname =
      TextEditingController(); //声明controller
  final TextEditingController _shuliang =
      TextEditingController(); //声明controller
  late bool isCustom;
  late FlutterScankit scanKit;
  bool isListTileVisible = false; // 定义变量
  bool hasOfflineData = false; // 是否有离线数据

  String code = "";

  @override
  void initState() {
    super.initState();
    // 检查离线数据
    hasOfflineData = checkOfflineData();
    scanKit = FlutterScankit();
    scanKit.addResultListen((val) {
      setState(() {
        code = val;
      });
      _barscode.text = code;
      final BuildContext context = this.context; // 获取BuildContext对象
      _getgoodsname(context, code);
    });
  }

  bool checkOfflineData() {
    // 在这里根据您的实际逻辑检查离线数据
    // 返回 true 表示有离线数据，返回 false 表示没有离线数据
    // 示例中暂时使用固定值来模拟结果
    return true;
  }

  @override
  void dispose() {
    scanKit.dispose();
    super.dispose();
  }

  Future<void> startScan() async {
    try {
      await scanKit.startScan(scanTypes: [ScanTypes.EAN13]);
    } on PlatformException {}
  }

  Future<void> saveDataOffline(String goodsCode, String goodsName,
      String barCode, double amount, String pdid) async {
    try {
      // 数据验证
      if (amount > 99999) {
        // 数量异常
        throw Exception('数量异常：商品名称：$goodsName，数量：$amount。数量将清空，请分批保存！');
      }

      // 保存到离线数据的pandian表
      await OfflineDatabase.saveDataToPandianTable(
          goodsCode, goodsName, barCode, amount, pdid);

      // 保存成功提示
      Get.snackbar(
        "保存成功",
        '商品名称：' + _goodsname.text + '，数量：' + amount.toString(),
        colorText: Colors.black,
        duration: const Duration(milliseconds: 3000),
      );
      _barscode.text = '';
      _goodscode.text = '';
      _goodsname.text = '';
      _shuliang.text = '';
    } catch (e) {
      // 异常处理
      print('保存失败：$e');
    }
  }

  void _showPopupWindow(BuildContext context) {
    TextEditingController textFieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('需要离线的商品分类编码'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '注意：下载离线数据会清除之前的离线数据和盘点记录！',
                style: TextStyle(
                  color: Colors.red, // 设置文本颜色为蓝色
                  fontSize: 16, // 设置文本大小为16
                ),
              ),
              // Text('分类编码'),
              TextField(
                controller: textFieldController,
                decoration: const InputDecoration(
                  hintText: '例如：0101',
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                String inputText = textFieldController.text.trim();
                if (inputText.isNotEmpty &&
                    inputText.length == 4 &&
                    inputText.startsWith("01")) {
                  _downloadOfflineData(inputText);
                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('提示'),
                        content: Text('分类编码不满足要求，请输入长度为4的编码'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('确定'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('下载'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
            ),
          ],
        );
      },
    );
  }

  void _downloadOfflineData(String categoryCode) async {
    _barscode.text = '开始下载离线';
    _goodscode.text = '请等待下载离线数据成功的提示';
    _goodsname.text = '暂时不要进行其他操作！';

    String url =
        'https://pd.chi-na.cn/app/lixiangoods.php?category=$categoryCode'; // 替换为实际的下载链接，将分类编码作为查询参数
    Dio dio = Dio();

    try {
      Response response = await dio.get(url);
      String data = response.data.toString();
      await _saveDataToDatabase(data);
      // 下载完成后的其他操作
      print('离线数据下载完成');
    } catch (error) {
      // 处理异常情况
      print('下载发生异常：$error');
    }
  }

  Future<void> _saveDataToDatabase(String jsondata) async {
    // 清空goods表
    await OfflineDatabase.clearData();
    // String jsonData =
    //'{"succeed":"1","data":[{"id":"209162","goodscode":"0103002378","goodsname":"红塔山(软经典)","BaseBarCode":"6901028315005"}]}';

    // 解析JSON数据
    var parsedData = json.decode(jsondata);
    var succeed = parsedData['succeed'];
    var data = parsedData['data'];
    int? recordCount = 0;
    var jsonCount = data.length;

    if (succeed == '1') {
      if (data is List && data.isNotEmpty) {
        int itemCount = 0; // 用于记录已下载的数据项数量

        for (var item in data) {
          if (item is Map<String, dynamic>) {
            var goodsData = Map<String, dynamic>.from(item);
            goodsData.remove('id'); // 移除ID字段
            await OfflineDatabase.insertData(goodsData);
            recordCount = await getGoodsRecordCount();

            itemCount++; // 每下载一个数据项，增加已下载的数量

            double percentage = (itemCount / jsonCount) * 100;
            // _shuliang.text = percentage.toStringAsFixed(2);
            int solidBlocks = (percentage ~/ 5); // 计算实心方块的数量，每5%一个方块
            String progress = '█' * solidBlocks +
                ' ' * (20 - solidBlocks); // 使用实心方块和空格字符表示下载进度
            _barscode.text = progress + percentage.toStringAsFixed(2);
          }
        }
      }
    }

    // 数据保存完成
    print('数据保存到数据库完成');
    // 获取当前goods记录数并打印
    // int? recordCount = await getGoodsRecordCount();
    // print('当前goods记录数：$recordCount');
    Get.snackbar(
      "下载离线成功",
      '离线商品数量：' + recordCount.toString(),
      colorText: Colors.red[700],
      duration: const Duration(milliseconds: 3000),
    );
    _barscode.text = '';
    _goodscode.text = '';
    _goodsname.text = '';
    _shuliang.text = '';
  }

  Future<int?> getGoodsRecordCount() async {
    Database database = await openDatabaseConnection();
    var result = await database.rawQuery('SELECT COUNT(*) FROM goods');
    int? count = Sqflite.firstIntValue(result);
    return count;
  }

  Future<Database> openDatabaseConnection() async {
    String databasePath = await getDatabasesPath();
    String databaseFile = join(databasePath, 'my_database.db');
    return openDatabase(databaseFile);
  }

// 查询离线数据_getgoodsname
  Future<void> _getgoodsname(BuildContext context, String query) async {
    Database database = await openDatabaseConnection();

    // 查询并打印匹配的数据
    List<Map<String, dynamic>> result = await database.query(
      'goods',
      where: 'goodscode = ? OR BaseBarCode = ?',
      whereArgs: [query, query],
    );
    if (result.isNotEmpty) {
      // print(result);
      for (var row in result) {
        _goodsname.text = row['goodsname'];
        _goodscode.text = row['goodscode'];
        _barscode.text = row['basebarcode'];
        FocusScope.of(context).unfocus(); // 取消当前焦点
        FocusScope.of(context).requestFocus(FocusNode()); // 获取焦点
        FocusScope.of(context)
            .requestFocus(_shuliangFocus); // 切换焦点到_shuliangFocus
//  code = '';
      }
    } else {
      print('No matching data found.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 根据某些条件设置 isListTileVisible 的值
    // isListTileVisible = c.quanxian.value;
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Color.fromARGB(255, 226, 224, 224),
        automaticallyImplyLeading: false,
        title: const Text("鸿宇盘点-离线"),
        backgroundColor: Color.fromRGBO(231, 115, 100, 1), 
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
              //_nextPage(-1);
            },
          );
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_downward), //下载离线数据
            onPressed: () {
              _showPopupWindow(context);
            }, //按钮事件处理成函数，用于执行重复代码
          ),
          
          IconButton(
            icon: const Icon(Icons.apps), //自定义图标
            onPressed: () {
              Get.to(const RequestRoute());
            }, //按钮事件处理成函数，用于执行重复代码
          ),
        ],
      ),

      // drawer: DrawerHead(), // 传递参数/ 抽取控件
      body: Container(
        padding: const EdgeInsets.all(8),
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: TextField(
                    focusNode: _barscodeFocus,
                    controller: _barscode,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: "商品条码",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _getgoodsname(context, value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: TextField(
                    focusNode: _goodscodeFocus,
                    controller: _goodscode,
                    decoration: const InputDecoration(
                      labelText: "商品编码/条码",
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: TextField(
                    controller: _goodsname,
                    decoration: const InputDecoration(
                      labelText: "商品名称",
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: TextField(
                    focusNode: _shuliangFocus,
                    controller: _shuliang,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: "数量/重量",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => '',
                    enabled: true,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 50,
                        margin: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          child: const Text('提交'),
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromRGBO(231, 115, 100, 1), 
                            onPrimary: Colors.white,
                          ),
                          onPressed: () async {
                            try {
                              // 解析数量表达式
                              var expressionGrammarDefinition =
                                  ExpressionGrammarParser({});
                              var parser = expressionGrammarDefinition.build();
                              var result = parser.parse(_shuliang.text
                                  .replaceAll(
                                      RegExp(r'([\-\–\—\−\－\_\ˉ])'), '-'));
                              var expression = result.value as Expression;
                              var str = expression.evaluate().toString();
                              double ssss = double.parse(str);

                              // 获取其他输入值
                              String goodsCode = _goodscode.text;
                              String goodsName = _goodsname.text;
                              String barCode = _barscode.text;
                              String pdid = c.pdid.value;

                              // 保存离线数据
                              await saveDataOffline(
                                goodsCode,
                                goodsName,
                                barCode,
                                ssss,
                                pdid,
                              );
                              FocusScope.of(context)
                                  .requestFocus(_barscodeFocus);
                            } catch (e) {
                              // 错误处理
                              print('保存失败：$e');
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Expanded(
              child: Card(
                color: Color.fromARGB(255, 248, 207, 222),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      '基本用法同在线盘点\n注意:下载离线数据会清除之前的离线数据和盘点数据\n注意:盘点结束后及时上传离线数据\n离线盘点需要先下载离线数据，点本页右上角的‘↓’按钮,然后输入离线数据的分类编码，点击下载按钮等待数据下载完成即可\n上传离线数据点击数据查看页右上角的‘↑’按钮,等待完成即可'),
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: "清除",
                onPressed: () {
                  FocusScope.of(context).requestFocus(_barscodeFocus); // 获取焦点
                  this.setState(() {
                    _barscode.text = '';
                    _goodscode.text = '';
                    _goodsname.text = '';
                    _shuliang.text = '';
                    this.code = '';
                  });
                },
                child: const Icon(Icons.clear),
                backgroundColor: Color.fromRGBO(231, 148, 104, 1),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: "btn2",
              onPressed: () async {
                _goodscode.text = '';
                isCustom = false;
                if (!await FlutterEasyPermission.has(
                    perms: _permissions, permsGroup: _permissionGroup)) {
                  FlutterEasyPermission.request(
                      perms: _permissions, permsGroup: _permissionGroup);
                } else {
                  startScan();
                  FocusScope.of(context).requestFocus(_barscodeFocus); // 获取焦点
                }
              },
              child: const Icon(Icons.crop_free),
              backgroundColor: Color.fromRGBO(86, 134, 219, 1),
            ),
          ),
        ],
      ),
    );
  }
}

class OfflineDatabase {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database == null) {
      _database = await openDatabase(
        join(await getDatabasesPath(), 'my_database.db'),
        version: 1,
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE IF NOT EXISTS goods (id INTEGER PRIMARY KEY AUTOINCREMENT, goodscode TEXT, goodsname TEXT, BaseBarCode TEXT)',
          );
        },
      );
    }
    return _database!;
  }

  static Future<void> insertData(Map<String, dynamic> data) async {
    Database database = await getDatabase();
    await database.insert('goods', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> clearData() async {
    Database database = await getDatabase();
    await database.delete('goods');
    await database.delete('pandian');
  }

  static Future<void> createPandianTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS pandian (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goodscode TEXT,
        goodsname TEXT,
        BarCode TEXT,
        Amount REAL,
        uptime DATETIME,
        BuildManCode TEXT,
        pdid TEXT,
        FOREIGN KEY (goodscode) REFERENCES goods(goodscode)
      )
    ''');
  }

  static Future<void> insertPandianData(Map<String, dynamic> data) async {
    Database database = await getDatabase();
    await createPandianTable(database);
    await database.insert('pandian', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> saveDataToPandianTable(String goodsCode, String goodsName,
      String barCode, double amount, String pdid) async {
    Database database = await getDatabase();
    await createPandianTable(database);

    DateTime now = DateTime.now();
    String uptime = now.toIso8601String();

    Map<String, dynamic> data = {
      'goodsCode': goodsCode,
      'goodsName': goodsName,
      'BarCode': barCode,
      'Amount': amount,
      'uptime': uptime,
      'BuildManCode': '', // Add the build man code if available
      'pdid': pdid,
    };

    await database.insert('pandian', data);
  }
}
