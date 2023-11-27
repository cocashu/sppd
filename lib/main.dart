import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import './main/pd_home.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:path_provider/path_provider.dart';

// void main() => runApp(const GetMaterialApp(home: Home()));
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  var databasesPath = await getDatabasesPath();
  var databasePath = join(databasesPath, 'my_database.db');
  var database = await openDatabase(databasePath, version: 1,
      onCreate: (db, version) async {
    // 创建 "goods" 表
    await db.execute('''
      CREATE TABLE goods (
        id INTEGER PRIMARY KEY,
        goodscode TEXT,
        goodsname TEXT,
        basebarcode
      )
    ''');

    // 创建 "pandian" 表
    await db.execute('''
      CREATE TABLE pandian (
        id INTEGER PRIMARY KEY,
        goodscode TEXT,
        goodsname TEXT,
        BarCode TEXT,
        Amount REAL,
        uptime DATETIME,
        BuildManCode TEXT,
        pdid TEXT,
        FOREIGN KEY (goodscode) REFERENCES goods(goodscode)
      )
    ''');
  });

  runApp(const GetMaterialApp(home: Home()));
}

class Controller extends GetxController {
  var username = 'jie'.obs;
  var pdid = '0001'.obs;
  final quanxian = 0.obs;
  final total = 0.00.obs;
  late final RxList<dynamic> cartItems = [].obs; //初始化
}

class ShoppingCartItem {
  String name;
  String code;
  double price;
  int quantity;

  ShoppingCartItem(
      {required this.name,
      required this.code,
      required this.price,
      this.quantity = 1});

  factory ShoppingCartItem.fromJson(Map<String, dynamic> json) {
    return ShoppingCartItem(
      name: json['name'],
      code: json['code'],
      price: json['price'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'price': price,
        'quantity': quantity,
      };
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    return ScreenUtilInit(
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('zh', 'CH'), Locale('en', 'US')],
          // title: '鸿云盘点',
          // You can use the library anywhere in the app even in theme
          theme: ThemeData(
            // primarySwatch: Colors.blue,
            primaryColor: const Color.fromRGBO(86, 134, 219, 1),

            textTheme: TextTheme(bodyMedium: TextStyle(fontSize: 30.sp)),
          ),
          home: child,
          builder: (_, child) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
              ),
              child: child!,
            );
          },
        );
      },
      child: const HomePage(title: '鸿云盘点'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) => HomePageScaffold(title: widget.title);
}
