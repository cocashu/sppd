import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart';
import '../main.dart';
import '../routes/pandian.dart';

class HomePageScaffold extends StatelessWidget {
  var title;

  HomePageScaffold({Key? key, required this.title}) : super(key: key);

  final Controller c = Get.put(Controller());
  //  HomePageScaffold({Key? key, required this.title}) : super(key: key);

  void printScreenInformation() {
    print('设备宽度:${1.sw}dp');
    print('设备高度:${1.sh}dp');
    print('设备的像素密度:${ScreenUtil().pixelRatio}');
    print('底部安全区距离:${ScreenUtil().bottomBarHeight}dp');
    print('状态栏高度:${ScreenUtil().statusBarHeight}dp');
    print('实际宽度和字体(dp)与设计稿(dp)的比例:${ScreenUtil().scaleWidth}');
    print('实际高度(dp)与设计稿(dp)的比例:${ScreenUtil().scaleHeight}');
    print('高度相对于设计稿放大的比例:${ScreenUtil().scaleHeight}');
    print('系统的字体缩放比例:${ScreenUtil().textScaleFactor}');
    print('屏幕宽度的0.5:${0.5.sw}dp');
    print('屏幕高度的0.5:${0.5.sh}dp');
    print('屏幕方向:${ScreenUtil().orientation}');
  }

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
              colorText: Colors.pink,
              duration: const Duration(milliseconds: 5000),
            );
            // c.quanxian.value = str[3];
            c.username.value = _username.text;
            c.pdid.value = _password.text;
            // 来自：https://www.jianshu.com/p/dee40971950f
            // Get.to(PandianRoute(), arguments: _username.text + ',' + str[1]);
            // Get.to(Other()); // 进入有返回
            Get.off(const PandianRoute()); // 进入后不得返回
          } else {
            Get.defaultDialog(
              title: '错误',
              titleStyle: const TextStyle(color: Colors.red),
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
          titleStyle: const TextStyle(color: Colors.red),
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
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: kToolbarHeight), // 距离顶部一个工具栏的高度
            buildTitle(), // Login
            buildTitleLine(), // Login下面的下划线
            const SizedBox(height: 60),
            buildEmailTextField(), // 输入邮箱
            const SizedBox(height: 30),
            buildPasswordTextField(context), // 输入密码
            buildForgetPasswordText(context), // 忘记密码
            const SizedBox(height: 60),
            buildLoginButton(context), // 登录按钮
            // const SizedBox(height: 40),
            // buildOtherLoginText(), // 其他账号登录
            const SizedBox(height: kToolbarHeight), // 距离顶部一个工具栏的高度
            buildRegisterText(context), // 注册
          ],
        ),
      ),
    );
  }

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

  Widget buildOtherLoginText() {
    return const Center(
      child: Text(
        '其他账号登录',
        style: TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }

  Widget buildLoginButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 45,
        width: 270,
        child: ElevatedButton(
            style: ButtonStyle(
                // 设置圆角
                shape: MaterialStateProperty.all(const StadiumBorder(
                    side: BorderSide(style: BorderStyle.none)))),
            child:
                Text('登录', style: Theme.of(context).primaryTextTheme.headline5),
            onPressed: () => _pdlogin()),
      ),
    );
  }

  Widget buildForgetPasswordText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            // Navigator.pop(context);
            print("忘记密码");
          },
          child: const Text("忘记密码？",
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ),
      ),
    );
  }

  Widget buildPasswordTextField(BuildContext context) {
    return TextFormField(
      // obscureText: _isObscure, // 是否显示文字
      // onSaved: (v) => _password = v!,
      validator: (v) {
        if (v!.isEmpty) {
          return '请输入密码';
        }
      },
      decoration: InputDecoration(
          labelText: "密码",
          suffixIcon: IconButton(
            icon: const Icon(
              Icons.remove_red_eye,
            ),
            onPressed: () {},
          )),
      focusNode: _passwordFocus,
      controller: _password,
      //指定controller
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      //完成按钮
      obscureText: true,
    );
  }

  Widget buildEmailTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: '账号'),
      autofocus: true,
      focusNode: _usernameFocus,
      controller: _username, //设置controller
      textInputAction: TextInputAction.next,
      validator: (v) {
        if (v!.isEmpty) {
          return '请输入账号';
        }
      },
    );
  }

  Widget buildTitleLine() {
    return Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 4.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            color: Colors.black,
            width: 40,
            height: 2,
          ),
        ));
  }

  Widget buildTitle() {
    return const Padding(
        padding: EdgeInsets.all(8),
        child: Text('鸿云盘点', style: TextStyle(fontSize: 42, color: Colors.red)));
  }
}
