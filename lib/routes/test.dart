import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easy_permission/easy_permissions.dart';
import 'package:flutter_scankit/flutter_scankit.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../main/yanse.dart';

const _permissions = [Permissions.CAMERA];

const _permissionGroup = [PermissionGroup.Camera];

class ChartData {
  final DateTime orderDate;
  final double purchasePrice;
  final double salePrice;

  ChartData(this.orderDate, this.purchasePrice, this.salePrice);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic>? data;

  final FocusNode _barscodeFocus = FocusNode();
  final TextEditingController _barscode =
      TextEditingController(); //声明controller
  final TextEditingController _goodscode =
      TextEditingController(); //声明controller
  late FlutterScankit scanKit;
  late bool isCustom;

  // 获取商品进价历史
  List<OrderData> _purchPriceData = [];
  List<OrderData> _salePriceData = [];
  void _fetchData(value) async {
    final response = await http.get(Uri.parse(
        'https://pd.chi-na.cn/app/yanshouapi.php?' + isGoodsCode(value)));
    final jsonData = jsonDecode(response.body);

    final mapData = Map<String, dynamic>.from(jsonData);
    // print('长度测试' + mapData.length.toString());
    if (mapData.isNotEmpty) {
      for (final item in mapData.entries) {
        final orderData = item.value;

        final orderDate = DateTime.parse(orderData['OrderDate']);
        final purchPrice = double.parse(orderData['PurchPrice']);
        final salePrice = double.parse(orderData['SalePrice']);

        _purchPriceData.add(OrderData(orderDate, purchPrice));
        _salePriceData.add(OrderData(orderDate, salePrice));
      }
    } else {
      _purchPriceData = [];
      _salePriceData = [];
    }

    setState(() {});
  }

  //扫码部分
  Future<void> startScan() async {
    try {
      await scanKit.startScan(scanTypes: [ScanTypes.EAN13]);
    } on PlatformException {}
  }

  String code = "";
  //判断条码是否符合标准
  bool tiaoma(String value) {
    int a = 0;
    int b = 0;
    int c = 0;
    int j = 1;
    for (var i in value.split('')) {
      // print(i.toString());
      if (j.isEven) {
        a = a + int.parse(i);
      }
      if (j.isOdd && j < 12) {
        b = b + int.parse(i);
      } else {
        c = int.parse(i);
      }
      j += 1;
    }
    if ((a * 3 + b) % 10 == c) {
      return true;
    } else {
      return false;
    }
  }

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

//判断商品编码和条码
  String isGoodsCode(String barcode) {
    // 如果是01开头长度为9 的商品编码
    if (barcode.length == 9) {
      if (barcode.substring(0, 2) == '01') {
        // print('商品编码');
        return 'goodscode=' + barcode;
      } else {
        // print('条码');
        return ' BaseBarCode=' + barcode;
      }
    } else {
      // print('条码');
      return ' BaseBarCode=' + barcode;
    }
  }

//原获取api数据
  Future<void> fetchData(value) async {
    print(isGoodsCode(value));
    final response = await http.get(Uri.parse(
        "https://pd.chi-na.cn/app/kcgoodsapi.php?" + isGoodsCode(value)));
    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body);
        _purchPriceData = [];
        _salePriceData = [];
        _fetchData(value);
        _barscode.text = '';
        // print(isGoodsCode(value));
      });
    } else {
      throw Exception('Failed to load data');
    }
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
        title: const Text("商品库存"),
        backgroundColor: ThemeColors.colorTheme,
      ),
      body: ListView(children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
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
                      labelText: "编码/条码",
                      border: OutlineInputBorder(),
                      // hintText: "如果系统没有查询到商品名称可以直接提交，并将给商品条码反馈给15804751607",
                    ),
                    onSubmitted: (value) => fetchData(value),
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  data != null &&
                          data!['data'] != null &&
                          data!['data']['goodsname'] != null
                      ? '${data!['data']['goodsname']}'
                      : '暂无数据',
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  data != null &&
                          data!['data'] != null &&
                          data!['data']['goodscode'] != null
                      ? 'Code：${data!['data']['goodscode']}'
                      : '暂无数据',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  data != null &&
                          data!["data"] != null &&
                          data!["data"]["goodsname"] != null
                      ? "Barcode: ${data!["data"]["BaseBarCode"]}"
                      : "暂无数据",
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  data != null &&
                          data!["data"] != null &&
                          data!["data"]["goodsname"] != null
                      ? "Quantity: ${data!["data"]["Amount"]}"
                      : "暂无数据",
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          width: double.infinity,
          child: SfCartesianChart(
            primaryXAxis: DateTimeAxis(dateFormat: DateFormat.yMd()), //时间轴
            primaryYAxis: NumericAxis(), //值轴
            //标题
            title: ChartTitle(text: '近10次进货(空白为无进货)'),
            //选中类型
            selectionType: SelectionType.series,
            //时间轴与值轴换位
            isTransposed: false,
            //选中手势
            selectionGesture: ActivationMode.singleTap,
            //图示
            legend: Legend(
                isVisible: true,
                iconHeight: 10,
                iconWidth: 10,
                //切换系列显示
                toggleSeriesVisibility: true,
                //图示显示位置
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
                //图示左右位置
                alignment: ChartAlignment.center),
            //跟踪球
            trackballBehavior: TrackballBehavior(
              enable: true,
            ),
            //打开工具提示
            tooltipBehavior: TooltipBehavior(
              enable: true,
              shared: true,
              activationMode: ActivationMode.singleTap,
            ),

            series: <ChartSeries>[
              LineSeries<OrderData, DateTime>(
                  name: '进货价格',
                  dataSource: _purchPriceData,
                  xValueMapper: (OrderData orderData, _) => orderData.date,
                  yValueMapper: (OrderData orderData, _) => orderData.price,
                  color: Colors.blue,
                  markerSettings: const MarkerSettings(isVisible: true)),
              LineSeries<OrderData, DateTime>(
                  name: '销售价格',
                  dataSource: _salePriceData,
                  // xValueMapper: (OrderData orderData, _) =>
                  //     DateFormat.yMMMMd('zh_CN')
                  //         .parse(DateFormat('yyyy-MM-dd').format(orderData.date)),
                  // // DateFormat('yyyy-MM-dd').parse(orderData.date as DateTime),
                  xValueMapper: (OrderData orderData, _) => orderData.date,
                  yValueMapper: (OrderData orderData, _) => orderData.price,
                  color: Colors.green,
                  markerSettings: const MarkerSettings(isVisible: true)),
            ],
          ),
        ),
      ]),
      floatingActionButton: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: "查询按钮",
                onPressed: () {
                  if (_barscode.text != '') {
                    fetchData(_barscode.text);
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
                _goodscode.text = '';
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
      ),
    );
  }
}

class OrderData {
  final DateTime date;
  final double price;

  OrderData(this.date, this.price);
}
