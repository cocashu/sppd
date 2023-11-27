import 'package:flutter/material.dart';
import './dingdan_all.dart';
import './caigoushenhe.dart';
import './caigouweishenhe.dart';

class caigoudinghuoPage extends StatelessWidget {
  const caigoudinghuoPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("采购订货"),
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
                text: "待审核",
              ),
              Tab(
                text: "待收货",
              ),
              Tab(
                text: "已收货",
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            dinghuoallPage(),
            caigouweishenhePage(),
            caigoushenhePage(),
            caigouweishenhePage(),
          ],
        ),
      ),
    );
  }
}
