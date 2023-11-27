import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easy_permission/easy_permissions.dart';
import 'package:flutter_scankit/flutter_scankit.dart';

// import './ApiDataDisplayWidget.dart';

const _permissions = [Permissions.CAMERA];

const _permissionGroup = [PermissionGroup.Camera];

class ApiCard extends StatefulWidget {
  const ApiCard({Key? key}) : super(key: key);

  @override
  _ApiCardState createState() => _ApiCardState();
}

class _ApiCardState extends State<ApiCard> {
  Map<String, dynamic>? _data;
  Map<String, dynamic>? _kcdata;
  List<Widget> _dataList = [];

  final _barscode = TextEditingController();

  late FlutterScankit scanKit;
  late bool isCustom;

  //扫码部分
  Future<void> startScan() async {
    try {
      await scanKit.startScan(scanTypes: [ScanTypes.EAN13]);
    } on PlatformException {}
  }

  void clearText() {
    _barscode.clear();
  }

  bool isProductCode(String code) {
    if (code.startsWith('01') && code.length == 9) {
      // 以 '01' 开头并且长度为 11 的字符串被定义为编码
      return true;
    } else if ((code.length == 8 || code.length == 13) &&
        RegExp(r'^\d+$').hasMatch(code)) {
      // 长度为 8 或者 13，且只包含数字的字符串被定义为条码
      return true;
    } else {
      return false;
    }
  }

  Future<void> _fetchData(value) async {
    // print(value);
    final response =
        await http.get(Uri.parse('http://172.16.19.30:8000/goods/$value'));
    final jsonData = utf8.decode(response.bodyBytes);
    final data = jsonDecode(jsonData);
    await Future.delayed(const Duration(seconds: 1));

    if (value != data!['data'][0]['goodscode']) {
      value = data!['data'][0]['goodscode'];
    }

    setState(() {
      _data = data;
      _fetchkcData(value);
      _testkcData(value);
      fetchData(value);
    });
  }

  Future<void> _fetchkcData(value) async {
    // print(value);
    final response =
        await http.get(Uri.parse('http://172.16.19.30:8000/kucun/$value'));
    final jsonData = utf8.decode(response.bodyBytes);
    final data = jsonDecode(jsonData);
    // print(jsonData);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _kcdata = data;
    });
  }

  Future<void> _testkcData(value) async {
    // print(value);
    final response =
        await http.get(Uri.parse('http://172.16.19.30:8000/kucun/$value'));
    // final jsonData = utf8.decode(response.bodyBytes);
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception("Failed to fetch data");
    }
  }

  void fetchData(value) async {
    var response =
        await http.get(Uri.parse('http://172.16.19.30:8000/sales/$value'));
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var list = jsonData['data'] as List;
      _dataList = buildListView(list);
    } else {
      // 处理 HTTP 错误
      print('HTTP 错误: ${response.statusCode}');
    }
    if (_dataList.isEmpty) {
      setState(() {
        _dataList.add(const Center(child: Text('查询不到进销存数据')));
      });
    }
  }

  List<Widget> buildListView(List<dynamic> dataList) {
    List<Widget> listItems = [];
    for (var data in dataList) {
      data.forEach((key, value) {
        var decodedValue = utf8.decode(value.toString().codeUnits);
        // 判断字符串是否是数值且包含小数点
        if (RegExp(r'^\d+\.\d+$').hasMatch(decodedValue)) {
          double parsedValue = double.parse(decodedValue);
          // 格式化双精度浮点数为两位小数
          decodedValue = parsedValue.toStringAsFixed(2);
        }
        if (key == 'GoodsCode') {
          key = '商品编码';
          return; // 跳出循环
        }
        if (key == 'CommonSaleAmount') {
          key = '普通销售金额';
        }
        if (key == 'PromotionSaleAmount') {
          key = '促销销售金额';
        }
        if (key == 'SaleCount') {
          key = '销售数量';
        }
        if (key == 'StockAmount') {
          key = '库存数量';
        }
        if (key == 'PurchStockMoney') {
          key = '采购库存金额';
        }
        if (key == 'ThreeMonthSaleAmount') {
          key = '近三个月销售金额';
        }
        if (key == 'PurchCost') {
          key = '采购成本';
        }
        if (key == 'PurchMoney') {
          key = '采购金额';
        }
        if (key == 'LastPurchDate') {
          key = '最后采购日期';
        }
        if (key == 'SupplierName') {
          key = '供应商名称';
        }
        if (key == 'SupplierPhone') {
          key = '供应商电话';
        }
        if (key == 'ReportDate') {
          key = '数据日期';
        }

        listItems.add(ListTile(title: Text("$key: $decodedValue")));
      });
    }
    return listItems;
  }

  String code = "";

  @override
  void initState() {
    super.initState();

    scanKit = FlutterScankit();
    scanKit.addResultListen((val) {
      setState(() {
        code = val;
      });
      _barscode.text = code;
    });
  }

  @override
  void dispose() {
    scanKit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商品查询'),
      ),
      body: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: buildernewMethod(context),
            ),
          ),
          Expanded(
            child: ListView(
              itemExtent: 25,
              children: _dataList,
            ),
          ),
        ],
      ),
      floatingActionButton: newMethodbuttton(),
    );
  }

  Stack newMethodbuttton() {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: "查询按钮",
              onPressed: () {
                if (_barscode.text != '') {
                  _fetchData(_barscode.text);
                  // print(_barscode.text);
                }
              },
              child: const Icon(Icons.check),
              backgroundColor: Colors.green,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            heroTag: "扫码按钮",
            onPressed: () async {
              _barscode.text = '';
              isCustom = false;
              if (!await FlutterEasyPermission.has(
                  perms: _permissions, permsGroup: _permissionGroup)) {
                FlutterEasyPermission.request(
                    perms: _permissions, permsGroup: _permissionGroup);
              } else {
                startScan();
                // FocusScope.of(context).requestFocus(_barscodeFocus); // 获取焦点
                // fetchData(_goodscode.text);
              }
            },
            child: const Icon(Icons.crop_free),
          ),
        ),
      ],
    );
  }

  Column buildernewMethod(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(6.0),
            child: TextFormField(
              controller: _barscode,
              //完成按钮
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,

              decoration: InputDecoration(
                  labelText: '编码/条码',
                  //文本框的尾部图标
                  suffixIcon: _barscode.text.isNotEmpty
                      ? IconButton(
                          //如果文本长度不为空则显示清除按钮
                          onPressed: () {
                            _barscode.clear();
                          },
                          icon: const Icon(Icons.cancel, color: Colors.grey))
                      : null),
              onFieldSubmitted: (value) => _fetchData(value),
            )),
        // DataDisplayPage(),
        SizedBox(
          width: MediaQuery.of(context).size.width, //与屏幕等宽
          child: _data == null
              ? const Text('请扫描商品条码或输入条码号码')
              : _data != null &&
                      _data!['data'].isEmpty &&
                      _kcdata!['data'].isEmpty
                  ? const Text('未查询到商品信息')
                  : Card(
                      // set the color of the card
                      color: Colors.blue[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        // side: const BorderSide(
                        //   color: Colors.blue,
                        //   width: 2.0,
                        // ),
                      ),
                      child: Column(
                        children: [
                          // 商品基本信息
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  // color: Colors.green
                                ),
                                child: Text(
                                  '${_data!['data'][0]['goodsname']}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(fontSize: 20),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child:
                                    Text('进${_data!['data'][0]['PurchPrice']}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 20,
                                        )),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  // color: Colors.green
                                ),
                                child:
                                    Text('售${_data!['data'][0]['SalePrice']}',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 20,
                                        )),
                              )
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  // color: Colors.green
                                ),
                                child: Text(
                                  '条码${_data!['data'][0]['basebarcode']}',
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '编码${_data!['data'][0]['goodscode']}',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),

                          Container(
                            color: _kcdata != null &&
                                    _kcdata!['data'] != null &&
                                    _kcdata!['data'][0]['amount'] != null &&
                                    _kcdata!['data'][0]['amount'] < 0
                                ? Colors.red
                                : Colors.transparent,
                            child: Text(
                              _kcdata != null &&
                                      _kcdata!['data'] != null &&
                                      _kcdata!['data'][0]['amount'] != null
                                  ? '实时库存:${_kcdata!['data'][0]['amount'].toString()}'
                                  : '0',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _kcdata != null &&
                                        _kcdata!['data'] != null &&
                                        _kcdata!['data'][0]['amount'] != null &&
                                        _kcdata!['data'][0]['amount'] < 0
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }
}
