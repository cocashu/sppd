import 'package:flutter/material.dart';
import './caigouall.dart';
import './caigoushenhe.dart';
import './caigouweishenhe.dart';

class caigourukuPage extends StatelessWidget {
  const caigourukuPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("采购入库"),
          actions: [
            IconButton(
              icon: const Icon(Icons.search), //搜索订单
              onPressed: () {
                ' Get.to(const RequestRoute())';
              }, //按钮事件处理成函数，用于执行重复代码
            ),
            IconButton(
              icon: const Icon(Icons.add), //添加订单
              onPressed: () {
                ' Get.to(const RequestRoute())';
              }, //按钮事件处理成函数，用于执行重复代码
            ),
          ],
          bottom: const TabBar(
            // labelColor: Colors.blue,
            // labelStyle: TextStyle(backgroundColor: Colors.green),
            unselectedLabelColor: Colors.black,
            tabs: [
              Tab(
                text: "全部",
              ),
              Tab(
                text: "未审核",
              ),
              Tab(
                text: "已审核",
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            caigouallPage(),
            caigouweishenhePage(),
            caigoushenhePage(),
          ],
        ),
      ),
    );
  }
}
