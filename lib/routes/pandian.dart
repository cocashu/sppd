// ignore_for_file: unnecessary_this

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../http.dart';
import 'request.dart';
// import 'package:http/http.dart' as http;
import 'package:get/get.dart' hide Response;
// ignore: import_of_legacy_library_into_null_safe
// import 'package:string_num_calculate/string_num_calculate.dart';
import 'package:flutter_easy_permission/easy_permissions.dart';
import 'package:flutter_scankit/flutter_scankit.dart';
import '../main.dart';
// import '../main/drawer.dart';
import 'package:expression_language/expression_language.dart';

const _permissions = [Permissions.CAMERA];

const _permissionGroup = [PermissionGroup.Camera];

class PandianRoute extends StatefulWidget {
  const PandianRoute({Key? key}) : super(key: key);

  @override
  _PandianRouteState createState() => _PandianRouteState();
}

class _PandianRouteState extends State<PandianRoute> {
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
      _getgoodsname(code);
    });
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

//判断商品编码和条码
  String isGoodsCode(String barcode) {
    // 如果是01开头长度为9 的商品编码
    if (barcode.length == 10) {
      if (barcode.substring(0, 2) == '01') {
        print('判断为商品编码');
        return 'goodscode=' + barcode;
      } else {
        print('判断为条码1');

        return ' BaseBarCode=' + barcode;
      }
    } else {
      print('判断为条码2');
      return ' BaseBarCode=' + barcode;
    }
  }

  //回调=>回调测试

  //回调=>查询商品数据
  void _getgoodsname(value) {
    if (value.length == 10 && value.toString().substring(0, 2) == '01') {
      //需要再判断一下是否已经查询过的条码
      print(" 编码长度 " + value.length.toString()); //提交按钮点击
      try {
        dio
            .get<String>(
                "https://pd.chi-na.cn/app/goodsapi.php?" + isGoodsCode(value))
            .then((r) {
          setState(() {
            var data = jsonDecode(r.data!.replaceAll(RegExp(r"\s"), "")); //3

            var data0 = data['succeed'];
            if (data0 == '1') {
              var data1 = data['data']; //3
              // _barscode.text = '';
              _goodsname.text = data1['goodsname'].toString();
              _goodscode.text = data1['goodscode'].toString();
              _barscode.text = data1['basebarcode'].toString();
              FocusScope.of(context).requestFocus(_shuliangFocus); // 获取焦点
            } else {
              // FocusScope.of(context).requestFocus(_barscodeFocus); // 获取焦点
              _barscode.text = '';
              _goodsname.text = '';
              _barscode.text = '';
              Get.snackbar(
                "商品编码未查询到",
                "强制盘点：在条码框输入商品编码、填写数量，当前可以继续盘点",
                colorText: Colors.pink,
                duration: const Duration(milliseconds: 5000),
              );
            }
          });
        });
      } catch (e) {
        print("sss");
        print(e);
      }
    } else {
      // if (value.length<18) {
      try {
        dio
            .get<String>(
                "https://pd.chi-na.cn/app/goodsapi.php?" + isGoodsCode(value))
            .then((r) {
          setState(() {
            var data = jsonDecode(r.data!.replaceAll(RegExp(r"\s"), "")); //3
            var data0 = data['succeed'];
            if (data0 == 1) {
              var data1 = data['data']; //3
              _goodsname.text = data1['goodsname'].toString();
              _goodscode.text = data1['goodscode'].toString();
              FocusScope.of(context).requestFocus(_shuliangFocus); // 获取焦点
              code = '';
            } else {
              // var data1 = data['data']; //3
              // _goodsname.text = data1['goodsname'].toString();
              // _goodscode.text = data1['goodscode'].toString();
              // print(data0);
              FocusScope.of(context).requestFocus(_barscodeFocus); // 获取焦点
              Get.snackbar(
                "商品条码未查询到",
                "请将商品条码反馈给信息部。强制盘点：在条码框输入商品编码、填写数量，当前可以继续盘点",
                colorText: Colors.red,
                duration: const Duration(milliseconds: 5000),
              );
            }
            print(r.data);
          });
        });
      } catch (e) {
        print("sss");
        print(e);
      }
    }
  }

  //回调=>上传盘点数据
  Future<void> _upgoods(value) async {
    var expressionGrammarDefinition = ExpressionGrammarParser({});
    var parser = expressionGrammarDefinition.build();
    var result =
        parser.parse(value.replaceAll(RegExp(r'([\-\–\—\−\－\_\ˉ])'), '-'));
    var expression = result.value as Expression;
    // var ssss = expression.evaluate();
    var str = '';
    str = expression.evaluate().toString();
    double ssss = double.parse(str);
    if (ssss > 99999) {
      //判断数量是否超大
      Get.snackbar(
        "数量异常",
        '商品名称：' +
            _goodsname.text +
            '，数量：' +
            ssss.toString() +
            '数量将清空,如果数量大于99999，请分批保存！',
        colorText: Colors.red,
        duration: const Duration(milliseconds: 5000),
      );
      _shuliang.text = '';
    } else {
      if (_goodscode.text.isEmpty) {
        _goodscode.text = _barscode.text;
        _goodsname.text = '强制盘点';
      }
      try {
        Response response;
        var data = {
          'goodscode': _goodscode.text,
          'barscode': _barscode.text,
          'shuliang': ssss,
          'zhidanren': c.username.value,
          'pdid': c.pdid.value
        };
        response = await Dio().post(
            "https://pd.chi-na.cn/app/upgoods_pandian.php",
            queryParameters: data);
        if (response.data.toString().trim() == 'ok') {
          Get.snackbar(
            "保存成功",
            '商品名称：' + _goodsname.text + '，数量：' + ssss.toString(),
            colorText: Colors.black,
            duration: const Duration(milliseconds: 3000),
          );
          _barscode.text = '';
          _goodscode.text = '';
          _goodsname.text = '';
          _shuliang.text = '';
          FocusScope.of(context).requestFocus(_barscodeFocus); // 获取焦点
        } else {
          _goodsname.text = response.data.toString().trim();
          FocusScope.of(context).requestFocus(_barscodeFocus); // 获取焦点
        }
        return response.data;
      } catch (e) {
        print("sss");
        print(e);
      }
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
        title: const Text("鸿宇盘点-在线"),
        backgroundColor: Color.fromRGBO(86, 134, 219, 1),
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
          child: ListView(children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.center, //垂直居中对齐
                crossAxisAlignment: CrossAxisAlignment.center, //垂直居中对齐
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: TextField(
                      focusNode: _barscodeFocus,
                      controller: _barscode,
                      //指定controller
                      autofocus: true,
                      //自动获取焦点
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      //完成按钮
                      decoration: const InputDecoration(
                        labelText: "商品条码",

                        border: OutlineInputBorder(),
                        // hintText: "如果系统没有查询到商品名称可以直接提交，并将给商品条码反馈给15804751607",
                      ),
                      onSubmitted: (value) => _getgoodsname(value),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: TextField(
                      focusNode: _goodscodeFocus,
                      controller: _goodscode, //指定controller
                      decoration: const InputDecoration(
                        labelText: "商品编码/条码",
                        border: OutlineInputBorder(),
                      ),
                      enabled: false, //是否禁用
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: TextField(
                      controller: _goodsname, //指定controller
                      decoration: const InputDecoration(
                        labelText: "商品名称",
                        border: OutlineInputBorder(),
                      ),
                      enabled: false, //是否禁用
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: TextField(
                      focusNode: _shuliangFocus,
                      controller: _shuliang,
                      //指定controller
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      //完成按钮
                      decoration: const InputDecoration(
                        labelText: "数量/重量",
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) => _upgoods(value),
                      enabled: true, //是否禁用
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // 让按钮宽度自适应
                      Expanded(
                          // 通过加外层容器设定尺寸来控制按钮的大小
                          child: Container(
                        height: 50,
                        margin: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          child: const Text('提交'),
                          style: ElevatedButton.styleFrom(
                            primary: const Color.fromRGBO(86, 134, 219, 1),
                            onPrimary: Colors.white,
                          ),
                          onPressed: () => _upgoods(_shuliang.text),
                        ),
                      ))
                    ],
                  ),
                 
                ]),
                 const Expanded(
                      child: Card(
                         color: Color.fromARGB(255, 248, 207, 222),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('数量支持加减乘除的计算。如12*2或23+5 \n盘点错误时可以在量前面加‘-’表示减少\n数量为商品的最小单位:(商品入库的单位) \n重量单位kg/千克/公斤精确到小数点后2位。\n盘点商品时如果未出现商品名字建议再扫一次条码试试'),
                    ),
                  ),),
          ])),
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
