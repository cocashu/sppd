import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../routes/lixianpandian.dart';
import '../routes/pandian.dart';
import '../main/drawer.dart';
import '../main/yanse.dart';
import '../routes/goods.dart';

// const _defaultColor = Color.fromRGBO(86, 134, 219, 1);

class PinterestGrid1 extends StatefulWidget {
  const PinterestGrid1({Key? key}) : super(key: key);

  @override
  _PinterestGridState createState() => _PinterestGridState();
}

class _PinterestGridState extends State<PinterestGrid1> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '店铺通',
      child: SingleChildScrollView(
        child: StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: const [
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 1,
              child: MenuEntry(
                title: '盘点工具',
                iconName: Icons.crop_free,
                destination: PandianRoute(),
                color: Color.fromRGBO(231, 115, 100, 1), // 将颜色作为参数传递进去
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 1,
              child: MenuEntry(
                title: '离线盘点',
                iconName: Icons.crop_free,
                destination: lixian_PandianRoute(),
                color: Color.fromRGBO(86, 134, 219, 1), // 将颜色作为参数传递进去
              ),
            ),
            // StaggeredGridTile.count(
            //   crossAxisCellCount: 2,
            //   mainAxisCellCount: 1,
            //   child: MenuEntry(
            //     title: '销售统计',
            //     iconName: Icons.bar_chart,
            //     destination: FirstRoute(),
            //     color: const Color.fromRGBO(86, 134, 219, 1),
            //   ),
            // ),
            // StaggeredGridTile.count(
            //   crossAxisCellCount: 2,
            //   mainAxisCellCount: 1,
            //   child: MenuEntry(
            //     title: '商品查询',
            //     iconName: Icons.search,
            //     destination: goodsCard(),
            //     color: Color.fromRGBO(242, 192, 81, 1), // 将颜色作为参数传递进去
            //   ),
            // ),
            // StaggeredGridTile.count(
            //   crossAxisCellCount: 2,
            //   mainAxisCellCount: 1,
            //   child: MenuEntry(
            //     title: '库存查询',
            //     iconName: Icons.search,
            //     destination: MyHomePage(),
            //     color: Color.fromRGBO(231, 148, 104, 1), // 将颜色作为参数传递进去
            //   ),
            // ),
            // StaggeredGridTile.count(
            //   crossAxisCellCount: 1,
            //   mainAxisCellCount: 1,
            //   child: MenuEntry(
            //     title: '采购计划',
            //     iconName: Icons.search,
            //     destination: caigoujihuaPage(),
            //     color: Color.fromRGBO(86, 134, 219, 1),
            //   ),
            // ),
            // StaggeredGridTile.count(
            //   crossAxisCellCount: 2,
            //   mainAxisCellCount: 1,
            //   child: MenuEntry(
            //     title: '采购订货',
            //     iconName: Icons.search,
            //     destination: caigoudinghuoPage(),
            //     color: Color.fromRGBO(127, 178, 243, 1),
            //   ),
            // ),
            // StaggeredGridTile.count(
            //   crossAxisCellCount: 1,
            //   mainAxisCellCount: 1,
            //   child: MenuEntry(
            //     title: '采购入库',
            //     iconName: Icons.search,
            //     destination: caigourukuPage(),
            //     color: Color.fromRGBO(231, 148, 104, 1), // 将颜色作为参数传递进去
            //   ),
            // ),

            // StaggeredGridTile.count(
            //   crossAxisCellCount: 3,
            //   mainAxisCellCount: 1,
            //   child: Tile(index: 6),
            // ),
            // StaggeredGridTile.count(
            //   crossAxisCellCount: 1,
            //   mainAxisCellCount: 1,
            //   child: Tile(index: 6),
            // ),
          ],
        ),
      ),
    );
  }
}

class MenuEntry extends StatelessWidget {
  const MenuEntry({
    Key? key,
    required this.title,
    required this.iconName,
    required this.destination,
    required this.color,
  }) : super(key: key);

  final String title;
  final Widget destination;
  final IconData iconName;
  final Color color; // 定义颜色参数

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color, // 使用颜色参数设置Card的颜色
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => destination,
            ),
          );
        },
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconName,
                    color: Colors.white, //
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white, //
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    Key? key,
    required this.title,
    this.topPadding = 0,
    required this.child,
  }) : super(key: key);

  final String title;
  final Widget child;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: ThemeColors.colorTheme,
      ),
      drawer: DrawerHead(), // 传递参数/ 抽取控件
      body: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: child,
      ),
    );
  }
}

class Tile extends StatelessWidget {
  const Tile({
    Key? key,
    required this.index,
    this.extent,
    this.backgroundColor,
    this.bottomSpace,
  }) : super(key: key);

  final int index;
  final double? extent;
  final double? bottomSpace;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      color: backgroundColor ?? ThemeColors.colorTheme,
      height: extent,
      child: Center(
        child: CircleAvatar(
          minRadius: 20,
          maxRadius: 20,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          child: Text('$index', style: const TextStyle(fontSize: 20)),
        ),
      ),
    );

    if (bottomSpace == null) {
      return child;
    }

    return Column(
      children: [
        Expanded(child: child),
        Container(
          height: bottomSpace,
          color: Colors.green,
        )
      ],
    );
  }
}
