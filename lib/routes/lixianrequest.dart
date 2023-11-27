import '../main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:dio/dio.dart';

class RequestRoute extends StatefulWidget {
  const RequestRoute({Key? key}) : super(key: key);

  @override
  _RequestRouteState createState() => _RequestRouteState();
}

class _RequestRouteState extends State<RequestRoute> {
  final Controller c = Get.put(Controller());
  List<Map<String, dynamic>>? offlineData; // 添加可为空的类型注解

  Future<Database> openDatabaseConnection() async {
    String databasePath = await getDatabasesPath();
    String databaseFile = join(databasePath, 'my_database.db');
    return openDatabase(databaseFile);
  }

  @override
  void initState() {
    super.initState();
    offlineData = null; // 初始化为null
    loadOfflineData();
  }

  Future<void> clearPandianTable() async {
    // 打开数据库连接
    final Database database = await openDatabaseConnection();

    // 执行删除操作
    await database.delete('Pandian');

    // 关闭数据库连接
    // await database.close();
  }

  Future<void> loadOfflineData() async {
    Database database = await openDatabaseConnection();
    List<Map<String, dynamic>> data = await database.query('pandian');
    setState(() {
      offlineData = data;
    });
  }

  Future<void> uploadDataToAPI() async {
    try {
      int totalItems = offlineData!.length; // 总条数
      int uploadedItems = 0; // 已上传条数
      for (var data in offlineData!) {
        var requestData = {
          'goodscode': data['goodscode'],
          'barscode': data['BarCode'],
          'shuliang': data['Amount'],
          'uptime': data['uptime'],
          'zhidanren': c.username.value,
          'pdid': c.pdid.value
        };

        Response response = await Dio().post(
          "https://pd.chi-na.cn/app/upgoods_pandian.php",
          queryParameters: requestData,
        );

        if (response.data.toString().trim() == 'ok') {
          // 上传成功处理
          print('Data uploaded successfully');
          uploadedItems++; // 增加已上传条数
          if (uploadedItems == totalItems) {
            Get.snackbar(
              "上传完成",
              '已上传总条数：$uploadedItems',
              colorText: Colors.black,
              duration: const Duration(milliseconds: 3000),
            );
            // 其他处理逻辑...
            // 清除离线盘点数据
            clearPandianTable();
          }
        } else {
          // 上传失败处理
          print('Data upload failed: ${response.data.toString().trim()}');
          // 其他处理逻辑...
        }
      }
    } catch (e) {
      // 异常处理
      print("An error occurred while uploading data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('离线产品列表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.red), //清空盘点数据
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('确认清空数据'),
                    content: const Text(
                      '您确定要清空盘点数据吗？',
                      style: TextStyle(
                        color: Colors.red, // 设置文本颜色为蓝色
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('取消'),
                        onPressed: () {
                          Navigator.of(context).pop(); // 关闭对话框
                        },
                      ),
                      TextButton(
                        child: const Text('确认'),
                        onPressed: () {
                          clearPandianTable(); // 执行清空数据操作
                          Navigator.of(context).pop(); // 关闭对话框
                          setState(() {
                            // 在清空数据后调用 setState 方法刷新界面
                            // 更新与数据相关的状态变量
                            // 这将触发界面的重建和刷新
                            offlineData = []; // 清空离线数据列表
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_upward), //上载离线数据
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('确认上传数据'),
                    content: const Text(
                      '您确定要上传离线盘点数据吗？\n 数据上传后将清除离线盘点数据！',
                      style: TextStyle(
                        color: Colors.red, // 设置文本颜色为蓝色
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('取消'),
                        onPressed: () {
                          Navigator.of(context).pop(); // 关闭对话框
                        },
                      ),
                      TextButton(
                        child: const Text('确认'),
                        onPressed: () {
                          uploadDataToAPI(); // 执行上传数据操作
                          Navigator.of(context).pop(); // 关闭对话框
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: offlineData != null && offlineData!.isNotEmpty
          ? ListView.builder(
              itemCount: offlineData!.length,
              itemBuilder: (BuildContext context, int index) {
                final row = offlineData![index];
                final goodsCode = row['goodscode'] ?? '';
                final goodsName = row['goodsname'] ?? '';
                final amount = row['Amount'] ?? '';
                // ignore: non_constant_identifier_names
                final BarCode = row['BarCode'] ?? '';
                final pdid = row['pdid'] ?? '';
                return ListTile(
                  title: Text('$goodsCode - $goodsName'),
                  subtitle: Text('条码:$BarCode盘点数量: $amount $pdid'),
                );
              },
            )
          : Center(
              child: Text('没有离线盘点数据'),
            ),
    );
  }
}
