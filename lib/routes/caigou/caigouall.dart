import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import '../../main.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'caigou_mingxi.dart';

class caigouallPage extends StatefulWidget {
  const caigouallPage({Key? key}) : super(key: key);

  @override
  _caigouallPageState createState() => _caigouallPageState();
}

class _caigouallPageState extends State<caigouallPage> {
  Controller c = Get.put(Controller());
  List<Order> orders = [];
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  //加载数据
  Future<void> _fetchData() async {
    String username = '';
    const int status = 4;
    //待处理权限问题
    if (c.quanxian.value >= 5) {
      username = 'admin9';
    } else {
      username = c.username.value;
    }
    print(username);
    final response = await http.get(Uri.parse(
        'http://pd.chi-na.cn/app/caigou/dingdan_api.php?username=$username&BillState=$status'));
    if (response.statusCode == 200) {
      print(response.body);
      final data = jsonDecode(response.body);
      if (jsonDecode(response.body)['succeed'] == '1') {
        final List<dynamic> orders = data['data'];
        setState(() {
          this.orders = orders.map((e) => Order.fromJson(e)).toList();
        });
      } else {
        print('获取数据失败');
      }
    } else {
      throw Exception('Failed to load data from API');
    }
    if (orders.isEmpty) {
      throw Exception('No data available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              key: UniqueKey(),
              background: Container(
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
              ),
              child: ListTile(
                title: Text(orders[index].buildManName +
                    '的订单  ' +
                    orders[index].buildTime),
                subtitle: Text('订单金额合计：' +
                    orders[index].totalAmount.toString()), //单据状态[0未确认1确认2终止3作废]
                trailing: orders[index].billState == '0'
                    ? TextButton(
                        child: const Text('审核中',
                            style: TextStyle(color: Colors.blue)),
                        onPressed: () {
                          setState(() {});
                        },
                      )
                    : orders[index].billState == '1'
                        ? TextButton(
                            child: const Text('已审核',
                                style: TextStyle(color: Colors.green)),
                            onPressed: () {
                              setState(() {});
                            },
                          )
                        : orders[index].billState == '2'
                            ? TextButton(
                                child: const Text('已终止',
                                    style: TextStyle(color: Colors.red)),
                                onPressed: () {
                                  setState(() {});
                                },
                              )
                            : TextButton(
                                child: const Text('已作废',
                                    style: TextStyle(color: Colors.grey)),
                                onPressed: () {
                                  setState(() {});
                                },
                              ),
                onTap: () {
                  print('点击订单查看明细');

                  Get.to(
                    () => CaigouMingxi(
                        billNumber: orders[index].billNumber,
                        billState: orders[index].billState,
                        username: orders[index].buildManName),
                  )?.then((value) {
                    if (value != null && value) {
                      _fetchData();
                    }
                  });
                },
              ),
            );
          },
        ),
      ),
      //测试按钮
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     print('点击添加订单');
      //     _fetchData();
      //   },
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

class Order {
  final String billNumber;
  final String buildDeptCode;
  final String billCate;
  final String billState;
  final String buildTime;
  final String buildManCode;
  final String buildManName;
  final String totalAmount;
  final String remark;

  Order({
    required this.billNumber,
    required this.buildDeptCode,
    required this.billCate,
    required this.billState,
    required this.buildTime,
    required this.buildManCode,
    required this.buildManName,
    required this.totalAmount,
    required this.remark,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      billNumber: json['BillNumber'],
      buildDeptCode: json['BuildDeptCode'],
      billCate: json['BillCate'],
      billState: json['BillState'],
      buildTime: json['BuildTime'],
      buildManCode: json['BuildManCode'],
      buildManName: json['BuildManName'],
      totalAmount: json['total_amount'],
      remark: json['Remark'],
    );
  }
}
