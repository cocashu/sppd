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
          ddorders = orders.map((e) => ddOrder.fromJson(e)).toList();
        });
      } else {
        print('获取数据失败');
      }
    } else {
      throw Exception('Failed to load data from API');
    }
  }

//订单采购提交
  Future<void> _dingdan_up(String billNumber, String billState) async {}

//计算c.cartItems的price×amount 金额
  void _calculateTotal() {
    double total = 0;
    for (var item in ddorders) {
      total += double.parse(item.amount) * double.parse(item.purchPrice);
      print(item.amount +
          '*' +
          item.purchPrice +
          '=' +
          (double.parse(item.amount) * double.parse(item.purchPrice))
              .toString());
    }

    // setState(() {
    c.total.value = total;

    // });
    print('总计：' + c.total.value.toString());
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
                          subtitle: Text(
                              '单位:公斤 \n预计单价:' + ddorders[index].purchPrice),
                          trailing: SizedBox(
                            width: 100,
                            height: 30,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              initialValue: ddorders[index].amount, //初始值
                              onChanged: (value) {
                                setState(() {
                                  ddorders[index].amount = value;
                                  _calculateTotal();
                                });
                              },
                            ),
                          ),
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
                                Obx(() => Text(
                                      c.total.value.toStringAsFixed(2),
                                      style: const TextStyle(fontSize: 20),
                                    )),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              if (c.quanxian > 2 && widget.billState == '1')
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
                      // Padding(
                      //   padding: const EdgeInsets.only(right: 20),
                      //   child: ElevatedButton(
                      //     style: ElevatedButton.styleFrom(
                      //       primary: Colors.red,
                      //     ),
                      //     onPressed: () {
                      //       // _shenhe(widget.billNumber, '0');//修改订单状态并提交采购数量
                      //     },
                      //     child: const Text(
                      //       "放弃采购",
                      //       style: TextStyle(fontSize: 20),
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(right: 20),
                      //   child: ElevatedButton(
                      //     // 背景颜色
                      //     style: ElevatedButton.styleFrom(
                      //       primary: Colors.green,
                      //     ),
                      //     onPressed: () {
                      //       // 权限等于9的人可以审核
                      //       // print(c.quanxian);
                      //     },
                      //     child: const Text(
                      //       "采购提交",
                      //       style: TextStyle(
                      //         fontSize: 20,
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: ElevatedButton(
                          // 背景颜色
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                          ),
                          onPressed: () {
                            // 权限等于9的人可以审核

                            ddorders.forEach((element) {
                              print(element.amount);
                            });
                          },
                          child: const Text(
                            "测试",
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
  late String amount;
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
