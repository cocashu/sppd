import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Response;
import '../main.dart';
import '../http.dart';

class Request_newRoute extends StatefulWidget {
  const Request_newRoute({Key? key}) : super(key: key);

  @override
  _Request_newRouteState createState() => _Request_newRouteState();
}

class _Request_newRouteState extends State<Request_newRoute> {
  late _JsonDataGridSource jsonDataGridSource;
  final Controller c = Get.put(Controller());
  final DataGridController _controller = DataGridController();

  List<_Product> productlist = [];
  TextEditingController? orderIdController,
      customerIdController,
      cityController,
      nameController,
      freightController,
      priceController;

  @override
  void initState() {
    super.initState();
    generateProductList();
    priceController = TextEditingController();
  }

  Future generateProductList() async {
    var response = await dio.get<String>(
        'https://pd.chi-na.cn/app/mxapi.php?username=' +
            c.username.value +
            '&pdid=' +
            c.pdid.value);
    var list = json
        .decode(response.data!.replaceAll(RegExp(r"\s"), ""))
        .cast<Map<String, dynamic>>();
    // print(response);
    productlist =
        list.map<_Product>((json) => _Product.fromJson(json)).toList();
    jsonDataGridSource = _JsonDataGridSource(productlist);
    return productlist;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          title: const Text("鸿宇商品库存"),
        ),
        body: Column(children: [
          Expanded(
              child: SfDataGrid(
            source: jsonDataGridSource,
            selectionMode: SelectionMode.single, //选择行
            //试试判断库存与盘点相差数量以调整商品行显示颜色
            // columnWidthMode: ColumnWidthMode.lastColumnFill,
            // columnWidthMode: ColumnWidthMode.auto,
            allowSorting: true, //为 false 来禁用单个列的排序
            allowMultiColumnSorting: true,
            allowTriStateSorting: true, //三种排序装态（升序、降序和取消排序）
            allowFiltering: true, //过滤选项
            allowEditing: true, //可以编辑修改
            editingGestureType: EditingGestureType
                .doubleTap, //双击修改，EditingGestureType.tap, //单击修改
            // selectionMode: SelectionMode.single, //编辑相关
            navigationMode: GridNavigationMode.cell, //编辑相关

            // footerFrozenColumnsCount: 1, //冻结右侧列 ；frozenColumnsCount: 1,//冻结左侧列
            tableSummaryRows: [
              //汇总合计行相关功能
              GridTableSummaryRow(
                  color: Colors.indigo,
                  showSummaryInRow: true,
                  title: '统计:{Count}条盘点记录，数量合计{Sum}',
                  titleColumnSpan: 3,
                  columns: [
                    const GridSummaryColumn(
                        name: 'Count',
                        columnName: 'id',
                        summaryType: GridSummaryType.count),
                    const GridSummaryColumn(
                        name: 'Sum',
                        columnName: 'Amount',
                        summaryType: GridSummaryType.sum)
                  ],
                  position: GridTableSummaryRowPosition.bottom),
            ],
            columns: [
              GridColumn(
                  columnName: 'id',
                  allowSorting: false, //禁止排序
                  allowFiltering: false, //禁止过滤
                  allowEditing: false, //禁用对特定列的编辑
                  width: ScreenUtil().setWidth(40),
                  label: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerRight,
                      child: const Text(
                        'ID',
                        overflow: TextOverflow.ellipsis,
                      ))),
              GridColumn(
                  columnName: 'goodscode',
                  allowEditing: false, //禁用对特定列的编辑
                  width: ScreenUtil().setWidth(110),
                  filterPopupMenuOptions: const FilterPopupMenuOptions(
                    canShowSortingOptions: false, //隐藏排序选项
                    // canShowClearFilterOption: false, //隐藏清除过滤器选项
                    showColumnName: false, //从“清除过滤器”选项中隐藏列名称
                  ),
                  label: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        '编码',
                        overflow: TextOverflow.ellipsis,
                      ))),
              GridColumn(
                  columnName: 'goodsname',
                  width: ScreenUtil().setWidth(130),
                  filterPopupMenuOptions: const FilterPopupMenuOptions(
                    canShowSortingOptions: false, //隐藏排序选项
                    canShowClearFilterOption: false, //隐藏清除过滤器选项
                    showColumnName: false, //从“清除过滤器”选项中隐藏列名称
                  ),
                  allowEditing: false, //禁用对特定列的编辑
                  label: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        '名称',
                        overflow: TextOverflow.ellipsis,
                      ))),
              GridColumn(
                  columnName: 'Amount',
                  width: ScreenUtil().setWidth(70),
                  allowSorting: false, //禁止排序
                  allowFiltering: false, //禁止过滤
                  label: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerRight,
                      child: const Text(
                        '数量',
                        overflow: TextOverflow.ellipsis,
                      ))),
            ],
            controller: _controller,
          )),
        ]));
  }
}

class Employee {
  Employee(this.id, this.goodscode, this.goodsname, this.Amount);
  final int id;
  final String goodscode;
  final String goodsname;
  final double Amount;
}

class EmployeeDataSource extends DataGridSource {
  dynamic newCellValue;

  /// Help to control the editable text in [TextField] widget.
  TextEditingController editingController = TextEditingController();

  @override
  void onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex,
      GridColumn column) {
    final dynamic oldValue = dataGridRow
            .getCells()
            .firstWhereOrNull((DataGridCell dataGridCell) =>
                dataGridCell.columnName == column.columnName)
            ?.value ??
        '';

    final int dataRowIndex = dataGridRows.indexOf(dataGridRow);

    if (newCellValue == null || oldValue == newCellValue) {
      return;
    }

    if (column.columnName == 'id') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<int>(columnName: 'id', value: newCellValue);
    } else if (column.columnName == 'goodscode') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'goodscode', value: newCellValue);
    } else if (column.columnName == 'goodsname') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'goodsname', value: newCellValue);
    } else {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<double>(columnName: 'Amount', value: newCellValue);
      print('编辑的值以更新' + newCellValue.toString());
      print('更新的name:' + rowColumnIndex.columnIndex.toString());
      var ss = dataGridRows[dataRowIndex].getCells()[1].value;
      print('获取商品编码：' + ss);
      //可以在此处增加修改商品盘点数量的选项
    }
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow,
      RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    // Text going to display on editable widget
    final String displayText = dataGridRow
            .getCells()
            .firstWhereOrNull((DataGridCell dataGridCell) =>
                dataGridCell.columnName == column.columnName)
            ?.value
            ?.toString() ??
        '';

    // The new cell value must be reset.
    // To avoid committing the [DataGridCell] value that was previously edited
    // into the current non-modified [DataGridCell].
    newCellValue = null;

    final bool isNumericType =
        column.columnName == 'id' || column.columnName == 'Amount';

    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: isNumericType ? Alignment.centerRight : Alignment.centerLeft,
      child: TextField(
        autofocus: true,
        controller: editingController..text = displayText,
        textAlign: isNumericType ? TextAlign.right : TextAlign.left,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 16.0),
        ),
        keyboardType: isNumericType ? TextInputType.number : TextInputType.text,
        onChanged: (String value) {
          if (value.isNotEmpty) {
            if (isNumericType) {
              newCellValue = double.parse(value);
            } else {
              newCellValue = value;
            }
          } else {
            newCellValue = null;
          }
        },
        onSubmitted: (String value) {
          // In Mobile Platform.
          // Call [CellSubmit] callback to fire the canSubmitCell and
          // onCellSubmit to commit the new value in single place.
          submitCell();
        },
      ),
    );
  }

//赋值相关？
  EmployeeDataSource({required List<Employee> employees}) {
    dataGridRows = employees
        .map<DataGridRow>((dataGridRow) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: dataGridRow.id),
              DataGridCell<String>(
                  columnName: 'goodscdoe', value: dataGridRow.goodscode),
              DataGridCell<String>(
                  columnName: 'goodsname', value: dataGridRow.goodsname),
              DataGridCell<double>(
                  columnName: 'Amount', value: dataGridRow.Amount),
            ]))
        .toList();
  }

  void updateDataGridSource() {
    notifyListeners();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  Widget? buildTableSummaryCellWidget(
      GridTableSummaryRow summaryRow,
      GridSummaryColumn? summaryColumn,
      RowColumnIndex rowColumnIndex,
      String summaryValue) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        summaryValue,
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  // style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      Color getColor() {
        if (dataGridCell.columnName == 'Amount') {
          if (dataGridCell.value >= 1000) {
            return Colors.red;
          } else if (dataGridCell.value < 10) {
            return Colors.blue[200]!;
          } else if (dataGridCell.value > 10 || dataGridCell.value < 1000) {
            return Colors.green;
          }
        }

        return Colors.transparent;
      }

      TextStyle? getTextStyle() {
        if (dataGridCell.columnName == 'Amount') {
          if (dataGridCell.value > 1000) {
            return const TextStyle(fontStyle: FontStyle.normal); //可以修改文字颜色
          } else if (dataGridCell.value > 100) {
            return const TextStyle(fontStyle: FontStyle.normal);
          }
        }

        return null;
      }

      return Container(
          color: getColor(),
          alignment: (dataGridCell.columnName == 'id' ||
                  dataGridCell.columnName == 'Amount')
              ? Alignment.centerRight
              : Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
            style: getTextStyle(),
          ));
    }).toList());
  }
}

class _Product {
  factory _Product.fromJson(Map<String, dynamic> json) {
    return _Product(
      ID: json['id'], //接收解析数据
      goodscode: json['goodscode'],
      goodsname: json['goodsname'],
      Amount: json['Amount'],
    );
  }

  _Product( //包定义
      {
    this.ID,
    this.goodscode,
    this.goodsname,
    this.Amount,
  });

  String? ID; //定义字段
  String? goodscode;
  String? goodsname;
  String? Amount;
}

class _JsonDataGridSource extends DataGridSource {
  _JsonDataGridSource(this.productlist) {
    buildDataGridRow();
  }

  List<DataGridRow> dataGridRows = [];
  List<_Product> productlist = [];

  void buildDataGridRow() {
    dataGridRows = productlist.map<DataGridRow>((dataGridRow) {
      return DataGridRow(cells: [
        DataGridCell<String>(
          columnName: 'ID',
          value: dataGridRow.ID,
        ),
        DataGridCell<String>(
          columnName: 'goodscode',
          value: dataGridRow.goodscode,
        ),
        DataGridCell<String>(
            columnName: 'goodsname', value: dataGridRow.goodsname),
        DataGridCell<String>(columnName: 'Amount', value: dataGridRow.Amount),
        // DataGridCell<double>(columnName: 'freight', value: dataGridRow.freight),
      ]);
    }).toList(growable: false);
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: [
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[0].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[1].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[2].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[3].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }
}
