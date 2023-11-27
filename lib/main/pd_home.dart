import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart';
import '../main.dart';
import '../routes/pandian.dart';
import '../main/home.dart';

class HomePageScaffold extends StatelessWidget {
  HomePageScaffold({Key? key, required this.title}) : super(key: key);

  final Controller c = Get.put(Controller());

  void printinput() {
    c.username.value = _username.text;
    c.pdid.value = _password.text;
    print(c.username.value);
    print(c.pdid.value);
  }

  _pdlogin() async {
    if (_username.text.trim().isNotEmpty) {
      if (_password.text.trim().isNotEmpty) {
        try {
          Response response;

          var data = {
            'username': _username.text,
            'password': _password.text,
          };
          response = await Dio().post("https://pd.chi-na.cn/app/login.php",
              queryParameters: data);
          // print(response.data.toString());
          List<String> str = response.data.toString().trim().split(',');
          if (str[0] == 'ok') {
            // 登录成功，跳转到盘点界面
            Get.snackbar(
              "登录成功",
              str[2],
              colorText: Color.fromRGBO(231, 148, 104, 1),
              duration: const Duration(milliseconds: 5000),
            );
            c.username.value = _username.text;
            c.pdid.value = _password.text;
            Get.off(const PinterestGrid1()); // 进入后不得返回
            // if (str[3] == '2') {
            //   c.quanxian.value = 2;
            // } else {
            //   c.quanxian.value = 1;
            // }
            c.quanxian.value = int.parse(str[3]);

            // 来自：https://www.jianshu.com/p/dee40971950f
            // Get.to(PandianRoute(), arguments: _username.text + ',' + str[1]);
            // Get.to(Other()); // 进入有返回
          } else {
            Get.defaultDialog(
              title: '错误',
              titleStyle:
                  const TextStyle(color: Color.fromRGBO(231, 148, 104, 1)),
              middleText: response.data.toString().trim(),
            );
          }
          return response.data;
        } catch (e) {
          print("sss");
          print(e);
        }
      } else {
        Get.defaultDialog(
          title: '错误',
          titleStyle: const TextStyle(color: Color.fromRGBO(231, 148, 104, 1)),
          middleText: '密码不能为空！',
        );
        // 来自 https://www.jianshu.com/p/44a0bf0369f1
      }
    } else {
      Get.defaultDialog(
        title: '错误',
        titleStyle: const TextStyle(color: Colors.red),
        middleText: '用户名不能为空！',
      );
    }
  }

  final TextEditingController _password =
      TextEditingController(); //声明controller
  final FocusNode _passwordFocus = FocusNode();

  //定义一个controller
  final TextEditingController _username = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          alignment: Alignment.bottomCenter, //设置控件内容的位置
          padding: const EdgeInsets.all(16),
          child: ListView(children: [
            const SizedBox(height: kToolbarHeight), // 距离顶部一个工具栏的高度
            buildTitle(), // Login
            buildTitleLine(), // Login下面的下划线
            const SizedBox(height: kToolbarHeight), // 距离顶部一个工具栏的高度
            Column(
                mainAxisAlignment: MainAxisAlignment.center, //垂直居中对齐
                crossAxisAlignment: CrossAxisAlignment.center, //垂直居中对齐
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: '账号',
                        labelStyle:
                            TextStyle(color: Color.fromRGBO(231, 148, 104, 1)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xffB6B6B6), width: 0.5)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(231, 148, 104, 1),
                                width: 1)),
                      ),

                      autofocus: true,
                      focusNode: _usernameFocus,
                      controller: _username, //设置controller
                      // style: TextStyle(color: Colors.grey), //修改颜色
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: "密码",
                        labelStyle:
                            TextStyle(color: Color.fromRGBO(231, 148, 104, 1)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xffB6B6B6), width: 0.5)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(231, 148, 104, 1),
                                width: 1)),
                      ),
                      focusNode: _passwordFocus,
                      controller: _password,
                      //指定controller
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      //完成按钮
                      obscureText: true,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // 让按钮宽度自适应
                      Expanded(
                          // 通过加外层容器设定尺寸来控制按钮的大小
                          child: Container(
                        height: ScreenUtil().setHeight(50),
                        margin: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color.fromRGBO(234, 116, 102, 1)),
                              // 设置圆角
                              shape:
                                  MaterialStateProperty.all(const StadiumBorder(
                                      side: BorderSide(
                                style: BorderStyle.none,
                              )))),

                          child: Text(
                            '登录',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                          onPressed: () => _pdlogin(),
                          // () => Get.to(Other()),
                        ),
                      ))
                    ],
                  ),
                ]),
            const SizedBox(height: kToolbarHeight), // 距离顶部一个工具栏的高度
            buildRegisterText(context), // 注册
          ])),
    );
  }

  final String title;
  Widget buildRegisterText(context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const Text('没有账号?'),
            GestureDetector(
              child: const Text('设计开发：鸿宇购物广场信息部',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              onTap: () {
                // print("点击注册");
              },
            )
          ],
        ),
      ),
    );
  }

  Widget buildTitleLine() {
    return Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 4.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            color: Color.fromRGBO(234, 116, 102, 1),
            width: 80,
            height: 2,
          ),
        ));
  }

  Widget buildTitle() {
    return const Padding(
        padding: EdgeInsets.all(8),
        child: Text('鸿云盘点',
            style: TextStyle(
                fontSize: 42, color: Color.fromRGBO(234, 116, 102, 1))));
  }
}
