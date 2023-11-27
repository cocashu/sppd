import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../main.dart';
import 'package:get/get.dart' hide Response;

class CaigouMingxi extends StatefulWidget {
  final String billNumber;
  final String billState;
  final String username;

  CaigouMingxi(
      {required this.billNumber,
      required this.billState,
      required this.username});

  @override
  _CaigouMingxiState createState() => _CaigouMingxiState();
}

class _CaigouMingxiState extends State<CaigouMingxi> {
  Controller c = Get.put(Controller());
  List<ddOrder> ddorders = [];
//加载订单明细
  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse(
        'http://pd.chi-na.cn/app/caigou/mingxi_api.php?billNumber=' +
            widget.billNumber));
    if (response.statusCode == 200) {
      // final data = jsonDecode(response.body);
      print(response.body);
      final data = jsonDecode(response.body);
      if (data['succeed'] == '1') {
        final List<dynamic> orders = data['data'];
        setState(() {
          this.ddorders = orders.map((e) => ddOrder.fromJson(e)).toList();
        });
      } else {
        print('获取数据失败');
      }
    } else {
      throw Exception('Failed to load data from API');
    }
  }

//订单审核
  Future<void> _shenhe(String billNumber, String billState) async {
    final response = await http.get(Uri.parse(
        'https://pd.chi-na.cn/app/caigou/shenhe_api.php?billNumber=' +
            billNumber +
            '&billState=' +
            billState +
            '&username=' +
            c.username.value));
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['succeed'] == '1') {
        Get.back(result: true);
      } else {
        print('获取数据失败');
      }
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Get.back(result: true);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('订单明细'),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: ddorders.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        ListTile(
                          title: Text(ddorders[index].goodsName +
                              '(' +
                              ddorders[index].goodsCode.toString() +
                              ')'),
                          subtitle: Text('数量：' +
                              ddorders[index].amount +
                              '单价：' +
                              ddorders[index].purchPrice),
                          trailing: Text('合计：' + ddorders[index].purchMoney),
                        ),
                        if (index == ddorders.length - 1)
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  '总计：',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  ddorders
                                      .fold<double>(
                                          0,
                                          (sum, order) =>
                                              sum +
                                              double.parse(order.purchMoney))
                                      .toStringAsFixed(2),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              // ignore: unrelated_type_equality_checks
              if (c.username == widget.username && widget.billState == '0')
                SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          "审核：",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                          ),
                          onPressed: () {
                            // 订单创建人可以终止订单

                            _shenhe(widget.billNumber, '2');
                          },
                          child: const Text(
                            "终止",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // ignore: unrelated_type_equality_checks
              if (c.username == widget.username && widget.billState == '1')
                SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          "审核状态：",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: ElevatedButton(
                          // 背景颜色
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                          ),
                          onPressed: () {
                            // 权限等于9的人可以审核
                            // print(c.quanxian);
                          },
                          child: const Text(
                            "已审核",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              //权限大于4可以审核订单
              if (c.quanxian > 4 && widget.billState == '0')
                SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          "审核：",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                          ),
                          onPressed: () {
                            _shenhe(widget.billNumber, '2');
                          },
                          child: const Text(
                            "拒绝",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            _shenhe(widget.billNumber, '1');
                          },
                          child: const Text(
                            "同意",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (c.quanxian > 4 && widget.billState == '1')
                SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          "审核状态：",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                          ),
                          onPressed: () {
                            _shenhe(widget.billNumber, '0');
                          },
                          child: const Text(
                            "反审核",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: ElevatedButton(
                          // 背景颜色
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                          ),
                          onPressed: () {
                            // 权限等于9的人可以审核
                            // print(c.quanxian);
                          },
                          child: const Text(
                            "已审核",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (c.quanxian > 3 && widget.billState == '2')
                SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          "审核状态：",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: ElevatedButton(
                          // 背景颜色
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                          ),
                          onPressed: () {
                            // 权限等于9的人可以审核
                            // print(c.quanxian);
                          },
                          child: const Text(
                            "已终止",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ));
  }
}

class ddOrder {
  final String buildDeptCode;
  final String billNumber;

  final String goodsCode;
  final String goodsName;
  final String amount;
  final String purchPrice;
  final String purchMoney;
  final String salePrice;
  final String lastPurchPrice;
  final String performAmount;
  final String performMoney;
  final String remark;
  final String storeAmount;

  ddOrder({
    required this.buildDeptCode,
    required this.billNumber,
    required this.goodsCode,
    required this.goodsName,
    required this.amount,
    required this.purchPrice,
    required this.purchMoney,
    required this.salePrice,
    required this.lastPurchPrice,
    required this.performAmount,
    required this.performMoney,
    required this.remark,
    required this.storeAmount,
  });

  factory ddOrder.fromJson(Map<String, dynamic> json) {
    return ddOrder(
      buildDeptCode: json['BuildDeptCode'],
      billNumber: json['BillNumber'],
      goodsCode: json['GoodsCode'],
      goodsName: json['Goodsname'],
      amount: json['Amount'],
      purchPrice: json['PurchPrice'],
      purchMoney: json['PurchMoney'],
      salePrice: json['SalePrice'],
      lastPurchPrice: json['LastPurchPrice'],
      performAmount: json['PerformAmount'],
      performMoney: json['PerformMoney'],
      remark: json['Remark'],
      storeAmount: json['StoreAmount'],
    );
  }
}
