import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';
import '../routes/goods.dart';
import '../main.dart';
import '../routes/test.dart';
import 'dart:convert';
import '../routes/goodscharts.dart';

class DrawerHead extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Controller c = Get.put(Controller());

    return Drawer(
      // 重要的Drawer组件
      child: ListView(
        // Flutter 可滚动组件
        padding: EdgeInsets.zero, // padding为0
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              "用户:${c.username}",
            ),
            // 副标题
            accountEmail: const Text('鸿宇家超市'),
            // Emails
            currentAccountPicture: const CircleAvatar(
              // 使用网络加载图像
              backgroundColor: Color.fromRGBO(127, 178, 243, 1),
            ),
            // 圆角头像
            decoration: const BoxDecoration(
              color: Color.fromRGBO(86, 134, 219, 1),
            ),
          ),
          Visibility(
              visible: true,
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('测试菜单'),
                onTap: () {
                  // Get.to(const dbsjPage());
                  print("You tapped Item 1"); // get.to
                },
              )),
          Visibility(
              visible: true,
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('销售报表'),
                onTap: () {
                  // Get.to(const testApiCard());
                  print("销售报表"); // get.to
                },
              )),
          Visibility(
              visible: true,
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('商品查询'),
                onTap: () {
                  Get.to(const goodsCard());
                  // print("You tapped Item 1"); // get.to
                },
              )),
          Visibility(
              visible: true,
              child: ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('商品库存test'),
                onTap: () {
                  Get.to(const MyHomePage());
                },
              )),
          Visibility(
              visible: true,
              child: ListTile(
                leading:
                    const Icon(Icons.brightness_6, color: Colors.black), //自定义图标
                title: const Text('显示模式'),
                onTap: () => Get.changeTheme(
                    Get.isDarkMode ? ThemeData.light() : ThemeData.dark()),
              )),
        ],
      ),
    );
  }
}
