import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';

// import 'package:flutter_cupertino_localizations/flutter_cupertino_localizations.dart';

class FirstRoute extends StatefulWidget {
  const FirstRoute({Key? key}) : super(key: key);

  @override
  _ApichartState createState() => _ApichartState();
}

class _ApichartState extends State<FirstRoute> {
  late List<CarSale> _source;
  late Map<String, Color> _colors;

  @override
  void initState() {
    _source = <CarSale>[
      CarSale(carName: '日百针织(李晓慧)', model: 'Elantra', totalScale: 198210),
      CarSale(carName: '日百针织(李晓慧)', model: 'Sonata', totalScale: 131803),
      CarSale(carName: '日百针织(李晓慧)', model: 'Tucson', totalScale: 114735),
      CarSale(carName: '日百针织(李晓慧)', model: 'Santa Fe', totalScale: 133171),
      CarSale(carName: '日百针织(李晓慧)', model: 'Accent', totalScale: 58955),
      CarSale(carName: '日百针织(李晓慧)', model: 'Veloster', totalScale: 12658),
      CarSale(carName: '日百针织(李晓慧)', model: 'loniq', totalScale: 11197),
      CarSale(carName: '日百针织(李晓慧)', model: 'Azera', totalScale: 3060),
      CarSale(carName: '日百针织(李晓慧)', model: 'Elantra', totalScale: 198210),
      CarSale(carName: '清洁用品(刘立红)', model: 'C-Class', totalScale: 77447),
      CarSale(carName: '清洁用品(刘立红)', model: 'GLE-Class', totalScale: 54595),
      CarSale(carName: '清洁用品(刘立红)', model: 'E/ CLS-CLass', totalScale: 51312),
      CarSale(carName: '清洁用品(刘立红)', model: 'GLC-Class', totalScale: 48643),
      CarSale(carName: '清洁用品(刘立红)', model: 'GLS-Class', totalScale: 322548),
      CarSale(carName: '清洁用品(刘立红)', model: 'Sprinter', totalScale: 27415),
      CarSale(carName: '清洁用品(刘立红)', model: 'CLA-Class', totalScale: 20669),
      CarSale(carName: '清洁用品(刘立红)', model: 'GLA-Class', totalScale: 24104),
      CarSale(carName: '清洁用品(刘立红)', model: 'S-Class', totalScale: 15888),
      CarSale(carName: '清洁用品(刘立红)', model: 'Metris', totalScale: 7579),
      CarSale(carName: '烟酒特产(赵玉梅)', model: '3-Series', totalScale: 59449),
      CarSale(carName: '烟酒特产(赵玉梅)', model: 'X5', totalScale: 50815),
      CarSale(carName: '烟酒特产(赵玉梅)', model: 'X3', totalScale: 40691),
      CarSale(carName: '烟酒特产(赵玉梅)', model: '5-Series', totalScale: 40658),
      CarSale(carName: '烟酒特产(赵玉梅)', model: '4-Series', totalScale: 39634),
      CarSale(carName: '烟酒特产(赵玉梅)', model: '2-Series', totalScale: 11737),
      CarSale(carName: '烟酒特产(赵玉梅)', model: '7-Series', totalScale: 9276),
      CarSale(carName: '烟酒特产(赵玉梅)', model: 'X1', totalScale: 30826),
      CarSale(carName: '烟酒特产(赵玉梅)', model: 'X6', totalScale: 6780),
      CarSale(carName: '烟酒特产(赵玉梅)', model: 'X4', totalScale: 5198),
      CarSale(carName: '烟酒特产(赵玉梅)', model: '6-Series', totalScale: 3355),
      CarSale(
          carName: '休闲调味(花艳艳)', model: 'Grand cherokee', totalScale: 240696),
      CarSale(carName: '休闲调味(花艳艳)', model: 'Cherokee', totalScale: 169822),
      CarSale(carName: '休闲调味(花艳艳)', model: 'Renegada', totalScale: 103434),
      CarSale(carName: '休闲调味(花艳艳)', model: 'Wrangler', totalScale: 190522),
      CarSale(carName: '休闲调味(花艳艳)', model: 'Compass', totalScale: 83523),
      CarSale(carName: '休闲调味(花艳艳)', model: 'Patriot', totalScale: 10735),
      CarSale(carName: '生鲜熟食(李宝莲)', model: '蔬果类', totalScale: 44715.26),
      CarSale(carName: '生鲜熟食(李宝莲)', model: '面点类', totalScale: 9997.73),
      CarSale(carName: '生鲜熟食(李宝莲)', model: '饮料类', totalScale: 20435.00),
      CarSale(carName: '生鲜熟食(李宝莲)', model: '水产类', totalScale: 2875.73),
      CarSale(carName: '生鲜熟食(李宝莲)', model: '肉品类', totalScale: 29813.08),
      CarSale(carName: '生鲜熟食(李宝莲)', model: '蛋类', totalScale: 3275.51),
      CarSale(carName: '生鲜熟食(李宝莲)', model: '鸿宇自营', totalScale: 12411.14),
      CarSale(carName: '生鲜熟食(李宝莲)', model: '炒货大全', totalScale: 1464.67),
      CarSale(carName: '购物场外', model: 'Rogue', totalScale: 103465),
      CarSale(carName: '购物场外', model: 'Sentra', totalScale: 18451),
      CarSale(carName: '购物场外', model: 'Murano', totalScale: 6732),
      CarSale(carName: '购物场外', model: 'Frontier', totalScale: 4360),
      CarSale(carName: '购物场外', model: 'Altima', totalScale: 4996),
      CarSale(carName: '购物场外', model: 'Versa', totalScale: 6772),
      CarSale(carName: '购物场外', model: 'Maxima', totalScale: 627),
      CarSale(carName: '购物场外', model: 'Titan', totalScale: 924),
      CarSale(carName: '购物场外', model: 'Armada', totalScale: 667),
      CarSale(carName: '购物场外', model: 'NV', totalScale: 1858),
      CarSale(carName: '购物场外', model: 'NV200', totalScale: 1602),
      CarSale(carName: '购物场外', model: 'Duke', totalScale: 1057),
    ];
    _colors = <String, Color>{
      '日百针织(李晓慧)': const Color.fromRGBO(220, 103, 171, 1.0),
      '烟酒特产(赵玉梅)': const Color.fromRGBO(160, 220, 103, 1.0),
      '清洁用品(刘立红)': const Color.fromRGBO(220, 210, 103, 1.0),
      '生鲜熟食(李宝莲)': const Color.fromRGBO(163, 103, 220, 1.0),
      '休闲调味(花艳艳)': const Color.fromRGBO(220, 105, 103, 1.0),
      'Ford': const Color.fromRGBO(103, 183, 220, 1.0),
      '购物场外': const Color.fromRGBO(103, 220, 187, 1.0),
    };
    super.initState();
  }

  @override
  void dispose() {
    _source.clear();
    super.dispose();
  }

  DateTimeRange daterange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    final start = daterange.start;
    final end = daterange.end;

    return Scaffold(
      appBar: AppBar(
        title: const Text('销售报表'),
        backgroundColor: const Color.fromRGBO(86, 134, 219, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('日期范围'),
                ),
                Expanded(
                    child: ElevatedButton(
                  child: Text('${start.year}-${start.month}-${start.day}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(127, 178, 243, 1),
                  ),
                  onPressed: PickerDateRange,
                )),
                const SizedBox(width: 20),
                Expanded(
                    child: ElevatedButton(
                  child: Text('${end.year}-${end.month}-${end.day}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(127, 178, 243, 1),
                  ),
                  onPressed: PickerDateRange,
                ))
              ],
            ),
            // 销售统计概览
            newcard(),
            // 分类销售额
            newsftree(),
          ],
        ),
      ),
    );
  }

  SfTreemap newsftree() {
    return SfTreemap(
      dataCount: _source.length,
      weightValueMapper: (int index) {
        return _source[index].totalScale!;
      },
      enableDrilldown: true,
      breadcrumbs: TreemapBreadcrumbs(
        builder: (BuildContext context, TreemapTile tile, bool isCurrent) {
          if (tile.group == 'Home') {
            return Icon(Icons.home, color: Colors.black);
          } else {
            return Text(tile.group, style: TextStyle(color: Colors.black));
          }
        },
        divider: Icon(Icons.chevron_right, color: Colors.black),
        position: TreemapBreadcrumbPosition.top,
      ),
      levels: [
        TreemapLevel(
          groupMapper: (int index) => _source[index].carName,
          labelBuilder: (BuildContext context, TreemapTile tile) {
            return Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 5.0),
              child: Text(
                tile.group,
                style: TextStyle(color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
          colorValueMapper: (TreemapTile tile) {
            return _colors[_source[tile.indices[0]].carName];
          },
        ),
        TreemapLevel(
          groupMapper: (int index) {
            return _source[index].model;
          },
          colorValueMapper: (TreemapTile tile) {
            return _colors[_source[tile.indices[0]].carName];
          },
          labelBuilder: (BuildContext context, TreemapTile tile) {
            return Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 5.0),
              child: Text(
                tile.group,
                style: TextStyle(color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
      ],
    );
  }

  // ignore: non_constant_identifier_names
  Future PickerDateRange() async {
    DateTimeRange? newdaterange = await showDateRangePicker(
      context: context,
      // locale: const Locale('zh', 'CN'),
      currentDate: DateTime.now(), // 当前日期
      firstDate: DateTime(2020, 7, 1),
      lastDate: DateTime.now(), // DateTime(2023, 4, 12),//不可超过当前日期
      helpText: '选择日期范围',
      confirmText: "确定", // 确认按钮 文案
      saveText: "完成", // 保存按钮 文案
      cancelText: '取消',
      initialDateRange: daterange,

      errorFormatText: '输入格式错误',
      errorInvalidText: '输入日期无效',
      fieldStartHintText: '开始日期',
      fieldEndHintText: '结束日期',
      fieldStartLabelText: '开始日期',
      fieldEndLabelText: '结束日期',
      errorInvalidRangeText: "开始日期大于结束日期", // 输入日期范围不合法 开始日期在结束日期之后
      // Locale class
      // locale: const Locale('zh', 'CH'), // 语言

      // 日期格式
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(86, 134, 219, 1),
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (newdaterange != null) {
      setState(() {
        daterange = newdaterange;
        print(daterange);
      });
    }
  }
}

class CarSale {
  const CarSale(
      {required this.carName,
      this.model,
      this.version,
      this.versionNumber,
      this.totalScale});
  final String carName;
  final String? model;
  final String? version;
  final String? versionNumber;
  final double? totalScale;
}

Card newcard() {
  return Card(
    color: Colors.lightBlue[50], // 设置背景颜色为蓝色
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Text(
          //   '销售统计概览',
          //   style: TextStyle(fontSize: 18.0),
          // ),
          // const SizedBox(height: 16.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('销售额'),
              const Text('¥100,000.00'),
              Column(
                children: [
                  Row(
                    children: const [
                      Text('同比'),
                      Text(
                        '+5%',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_upward,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    children: const [
                      Text('环比'),
                      Text(
                        '-5%',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_downward,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('销售量'),
              const Text('1,000'),
              Column(
                children: [
                  Row(
                    children: const [
                      Text('同比'),
                      Text(
                        '+5%',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_upward,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    children: const [
                      Text('环比'),
                      Text(
                        '-3%',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_downward,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('利润'),
              const Text('¥20,000.00'),
              Column(
                children: [
                  Row(
                    children: const [
                      Text('同比'),
                      Text(
                        '+5%',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_downward,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    children: const [
                      Text('环比'),
                      Text(
                        '+8%',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_upward,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
