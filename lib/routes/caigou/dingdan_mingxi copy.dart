import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../main.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';

class GoodsCartItem {
  String goodsname;
  String goodscode;
  String PurchPrice;
  String Amount;
  bool isSelected = false;

  GoodsCartItem({
    required this.goodsname,
    required this.goodscode,
    required this.PurchPrice,
    required this.Amount,
    // required this.isSelected,
  });

  factory GoodsCartItem.fromJson(Map<String, dynamic> json) {
    return GoodsCartItem(
      goodsname: json['goodsname'],
      goodscode: json['goodscode'],
      PurchPrice: json['PurchPrice'],
      Amount: json['Amount'],
      // isSelected: false
    );
  }

  Map<String, dynamic> toJson() => {
        'goodsname': goodsname,
        'goodscode ': goodscode,
        'PurchPrice': PurchPrice,
        'Amount': Amount,
        // 'isSelected': false
      };

  void add(cartItem) {}
}

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
  final List<GoodsCartItem> _goodsItems = [];

  //读取
  void loadCartItemsFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cartItemsJson = prefs.getString('cartItems');
    if (cartItemsJson != null) {
      List<dynamic> cartItemsList = jsonDecode(cartItemsJson);
      print(jsonDecode(cartItemsJson));
      if (c.cartItems.isNotEmpty) {
        c.cartItems.addAll(cartItemsList
            .map((item) => ShoppingCartItem.fromJson(item))
            .toList());
      }
      // else {
      //   c.cartItems = cartItemsList
      //       .map((item) => ShoppingCartItem.fromJson(item))
      //       .toList();
      // }
      setState(() {});
    }
  }

//加载订单明细
  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse(
        'http://pd.chi-na.cn/app/caigou/mingxi_api.php?billNumber=' +
            widget.billNumber));
    if (response.statusCode == 200) {
      print('网络数据');
      final data = jsonDecode(response.body);
      if (data['succeed'] == '1') {
        final List<dynamic> orders = data['data'];
        _goodsItems.addAll(
            orders.map((item) => GoodsCartItem.fromJson(item)).toList());
        setState(() {});
        print(orders);
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

//计算c.cartItems的price×amount 金额
  void _calculateTotal() {
    double total = 0;
    for (var item in ddorders) {
      total += double.parse(item.amount) * double.parse(item.purchPrice);
    }

    // setState(() {
    c.total.value = total;

    // });
    print(c.total.value);
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  //清除缓存数据
  void _submitData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('cartItems');
    setState(() {
      c.cartItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Get.back(result: true);
          _submitData();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('订单明细'),
          ),
          body: Column(
            children: [
              Expanded(
                child: Obx(() => ListView.builder(
                      itemCount: c.cartItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(c.cartItems[index].name +
                              '(' +
                              c.cartItems[index].code.toString() +
                              ')'),
                          subtitle: Text('前次进价：' +
                              c.cartItems[index].price.toString() +
                              '元/公斤' +
                              '  订货：' +
                              c.cartItems[index].quantity.toString() +
                              '公斤\n预计金额' +
                              (c.cartItems[index].price *
                                      c.cartItems[index].quantity)
                                  .toStringAsFixed(2) +
                              "元"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                c.cartItems.removeAt(index);
                                _calculateTotal();
                              });
                            },
                          ),
                          onTap: () {
                            // _editItem(index);
                            // _calculateTotal();
                          },
                        );
                      },
                    )),
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
                            // print(c.quanxian);
                            _calculateTotal();
                            loadCartItemsFromLocal();
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
