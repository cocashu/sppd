import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';

// import 'package:flutter_cupertino_localizations/flutter_cupertino_localizations.dart';

class FirstRoute extends StatefulWidget {
  const FirstRoute({Key? key}) : super(key: key);

  @override
  _ApichartState createState() => _ApichartState();
}

class _ApichartState extends State<FirstRoute> {
  late List<SocialMediaUsers> _source;

  @override
  void initState() {
    _source = <SocialMediaUsers>[
      const SocialMediaUsers('日百针织(李晓慧)', 'Facebook', 25.4),
      const SocialMediaUsers('烟酒特产(赵玉梅)', 'Instagram', 19.11),
      const SocialMediaUsers('清洁用品(刘立红)', 'Facebook', 13.3),
      const SocialMediaUsers('生鲜熟食(李宝莲)', 'Instagram', 10.65),
      const SocialMediaUsers('休闲调味(花艳艳)', 'Twitter', 7.54),
      const SocialMediaUsers('购物场外', 'Instagram', 4.93),
    ];
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
        return _source[index].usersInMillions;
      },
      levels: [
        TreemapLevel(
          groupMapper: (int index) {
            return _source[index].country;
          },
          // color: Colors.teal[200],
          // color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
          // colorValueMapper: (TreemapTile tile) {
          //   return tile.weight * 100;
          // },
          padding: const EdgeInsets.all(1.5),
          labelBuilder: (BuildContext context, TreemapTile tile) {
            return Text(
              tile.group + ',' + tile.weight.toString() + '万',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
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

class SocialMediaUsers {
  const SocialMediaUsers(this.country, this.socialMedia, this.usersInMillions);

  final String country;
  final String socialMedia;
  final double usersInMillions;
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
