import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import 'goods.dart';
import 'package:get/get.dart' hide Response;

// class caigoujihua_addPage extends StatefulWidget {

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

class ShoppingCartPage extends StatefulWidget {
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  // List<ShoppingCartItem> _cartItems = [];
  final List<GoodsCartItem> _goodsItems = [];
  // double _total = 0;
  final Controller c = Get.put(Controller());
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemCodeController = TextEditingController();
  final TextEditingController _itemjiageController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemCodeController.dispose();
    _itemjiageController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _addItem() async {
    String? itemName;
    String? itemCode;
    String? itemjiage;
    int quantity = 1;
//添加商品窗口
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("添加商品"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _itemNameController,
                decoration: const InputDecoration(
                  labelText: "商品名称",
                ),
                onChanged: (value) {
                  itemName = value;
                  for (var item in _goodsItems) {
                    if (value == item.goodsname) {
                      _itemCodeController.text = item.goodscode;
                      _itemjiageController.text = item.PurchPrice;
                      break;
                    }
                  }
                },
              ),
              TextField(
                controller: _itemCodeController,
                decoration: const InputDecoration(
                  labelText: "商品编码",
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  itemCode = value;
                },
              ),
              TextField(
                controller: _itemjiageController,
                decoration: const InputDecoration(
                  labelText: "历史进价/公斤",
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  itemjiage = value;
                },
              ),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: "数量/公斤",
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  quantity = int.tryParse(value) ?? 1;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("取消"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("添加"),
              onPressed: () {
                if (itemName != null && itemName!.isNotEmpty) {
                  setState(() {
                    c.cartItems.add(ShoppingCartItem(
                        name: itemName!,
                        code: itemCode!,
                        price: double.parse(
                            _itemjiageController.text), //(itemjiage!),
                        quantity: quantity));
                  });
                }

                if (itemCode != null && itemCode!.isNotEmpty) {
                  // Do something with item code
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    _itemNameController.clear();
    _itemCodeController.clear();
    _itemjiageController.clear();
    _quantityController.clear();
  }

//修改商品数量窗口
  void _editItem(int index) async {
    int quantity = c.cartItems[index].quantity;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("修改订货数量"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(c.cartItems[index].name),
              TextField(
                decoration: const InputDecoration(
                  labelText: "数量",
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  quantity = int.tryParse(value) ?? 1;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("取消"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("保存"),
              onPressed: () {
                setState(() {
                  c.cartItems[index].quantity = quantity;
                  _calculateTotal();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//保存数据
  void saveCartItemsToLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cartItemsJson = jsonEncode(c.cartItems);
    await prefs.setString('cartItems', cartItemsJson);
  }

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

  //删除
  void _submitData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('cartItems');
    setState(() {
      c.cartItems.clear();
    });
  }

//加载数据
  void _fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cachedData');
    if (cachedData != null) {
      //如果本地有缓存数据，就直接使用 调试时修改数据后，需要删除缓存数据
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
      print('网络数据');
      _goodsItems
          .addAll(data.map((item) => GoodsCartItem.fromJson(item)).toList());
      setState(() {});

      // Save fetched data to local storage
      await prefs.setString('cachedData', response.body);
    } else {
      throw Exception('Failed to load data from API');
    }
  }

//提交数据到服务器
  Future<void> submitCartItems(cartItems) async {
    var headers = {
      'User-Agent': 'Apifox/1.0.0 (https://www.apifox.cn)',
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Host': 'pd.chi-na.cn',
      'Connection': 'keep-alive'
    };
    var request = http.Request(
        'POST', Uri.parse('http://pd.chi-na.cn/app/caigou_add.php'));
    request.body = json.encode({
      "cartItems": jsonEncode(cartItems),
      "zhidanren": c.username.value,
      "total": c.total.value
    });
    request.headers.addAll(headers);
    // print(request.body); //发送内容请求
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Get.snackbar("采购订单", '提交成功',
          colorText: Colors.black,
          duration: const Duration(milliseconds: 3000));

      // //  打印返回值
      print(await response.stream.bytesToString());
      // if (response.stream.bytesToString() == 'ok') {
      //   Get.snackbar("采购订单", '提交成功',
      //       colorText: Colors.black,
      //       duration: const Duration(milliseconds: 3000));
      //   _submitData();
      // }
      _submitData();
      c.total.value = 0;
    } else {
      print(response.reasonPhrase);
    }
  }

//计算c.cartItems的price×amount 金额
  void _calculateTotal() {
    double total = 0;
    for (var item in c.cartItems) {
      total += item.price * item.quantity;
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
    // loadCartItemsFromLocal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("订货明细单"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add), //添加商品
            onPressed: () {
              Get.to(() => MyDialog())?.then((value) {
                if (value != null && value) {
                  loadCartItemsFromLocal();
                  _calculateTotal();
                }
              });
            }, //按钮事件处理成函数，用于执行重复代码
          ),
          IconButton(
            icon: const Icon(
              Icons.clear,
              color: Colors.red,
            ), //添加商品
            onPressed: () {
              Get.defaultDialog(
                title: "提示",
                middleText: "是否清空订货单？",
                textConfirm: "确定",
                textCancel: "取消",
                confirmTextColor: Colors.white,
                // cancelTextColor: Colors.white,
                buttonColor: Colors.blue,
                onConfirm: () {
                  setState(() {
                    c.cartItems.clear();
                    _calculateTotal();
                  });
                  Get.back();
                },
                onCancel: () {
                  // Get.back();
                },
              );
            }, //按钮事件处理成函数，用于执行重复代码
          ),
        ],
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
                        _editItem(index);
                        _calculateTotal();
                      },
                    );
                  },
                )),
          ),
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "合计：",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Obx(() => Text(
                      c.total.value.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 20),
                    )),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      submitCartItems(c.cartItems);
                    },
                    child: const Text(
                      "提交",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
