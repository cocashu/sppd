// 弹出窗口
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hy_goods2/routes/caigou/caigoujihua_add.dart';
import 'goodsl.dart'; //暂时不用
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

class MyDialog extends StatefulWidget {
  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  final TextEditingController _controller = TextEditingController();
  List<GoodsCartItem> _goodsItems = [];

  final Controller c = Get.put(Controller());
  //加载商品数据
  void _fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cachedData');
    if (cachedData != null) {
      print('本地数据');
      final List<dynamic> data = jsonDecode(cachedData);
      _goodsItems
          .addAll(data.map((item) => GoodsCartItem.fromJson(item)).toList());
      setState(() {});
      return; // Exit early if cached data is available
    }

    // Fetch data from API if cached data is not available
    final response =
        await http.get(Uri.parse('https://pd.chi-na.cn/app/sql_api.php'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _goodsItems
          .addAll(data.map((item) => GoodsCartItem.fromJson(item)).toList());
      setState(() {});

      // Save fetched data to local storage
      await prefs.setString('cachedData', response.body);
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  String? itemName;
  String? itemCode;
  String? itemjiage;
  double? a;
  int quantity = 1;
  // whatYouWantOperation() {
  //   //在这里写你期望的返回按钮操作
  //   // Get.back(result: true);
  //   print('返回按键操作');
  //   return null;
  // }

  @override
  Widget build(BuildContext context) {
    final _controller = TextEditingController();
    return WillPopScope(
      onWillPop: () async {
        Get.back(result: true);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('商品列表'),
          leading: Builder(builder: (context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Get.back(result: true);
              },
            );
          }),
        ),
        body: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "商品名称",
              ),
              onChanged: (value) {
                setState(() {
                  _goodsItems = _goodsItems
                      .where((item) => item.goodsname.contains(value))
                      .toList();
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _goodsItems.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    // leading: Icon(Icons.shopping_cart),
                    title: Text(_goodsItems[index].goodsname +
                        "(" +
                        _goodsItems[index].goodscode +
                        ")"),
                    subtitle: Text(
                        "前次进价：${_goodsItems[index].PurchPrice}元,\n前次数量：${_goodsItems[index].Amount}"), //数量待调整api
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        QuantitySelector(
                          quantity:
                              10, //double.parse(_goodsItems[index].Amount).toInt()
                          onQuantityChanged: (newQuantity) {
                            quantity = newQuantity;
                            // print(newQuantity); //这里可以获取到数量
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.blue),
                          onPressed: () {
                            // print("选择后直接添加到购物车");
                            print(
                                "You tapped on ${_goodsItems[index].goodsname}${_goodsItems[index].goodscode} ${_goodsItems[index].PurchPrice} ");
                            // if (_goodsItems[index].goodsname != null &&
                            //     _goodsItems[index].goodsname.isNotEmpty) {
                            c.cartItems.add(ShoppingCartItem(
                                name: _goodsItems[index].goodsname,
                                code: _goodsItems[index].goodscode,
                                price: double.parse(_goodsItems[index]
                                    .PurchPrice), //(itemjiage!),
                                quantity: quantity));

                            // loadCartItemsFromLocal();
                            // }
                          },
                        ),
                      ],
                    ),

                    onTap: () {
                      //  _fetchData();
                      print("按前次数量后直接添加到购物车");
                      setState(() {
                        _goodsItems[index].isSelected = true;
                      });
                      c.cartItems.add(ShoppingCartItem(
                          name: _goodsItems[index].goodsname,
                          code: _goodsItems[index].goodscode,
                          price: double.parse(
                              _goodsItems[index].PurchPrice), //(itemjiage!),
                          quantity:
                              double.parse(_goodsItems[index].Amount).toInt()));
                    },
                    tileColor:
                        _goodsItems[index].isSelected ? Colors.grey : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
