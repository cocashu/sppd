import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../http.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:get/get.dart' hide Response;
import '../main.dart';

class RequestRoute extends StatefulWidget {
  const RequestRoute({Key? key}) : super(key: key);

  @override
  _RequestRouteState createState() => _RequestRouteState();
}

class _RequestRouteState extends State<RequestRoute> {
  final Controller c = Get.put(Controller());
  late _JsonDataGridSource jsonDataGridSource;
  List<_Product> productlist = [];

  Future generateProductList() async {
    var response = await dio.get<String>(
        'https://pd.chi-na.cn/app/mxapi.php?username=' +
            c.username.value +
            '&pdid=' +
            c.pdid.value);
    var list = json
        .decode(response.data!.replaceAll(RegExp(r"\s"), ""))
        .cast<Map<String, dynamic>>();

    productlist =
        list.map<_Product>((json) => _Product.fromJson(json)).toList();
    jsonDataGridSource = _JsonDataGridSource(productlist);
    return productlist;
  }

  List<GridColumn> getColumns() {
    List<GridColumn> columns;
    columns = ([
      GridColumn(
        columnName: '序号',
        allowSorting: false, //禁止排序
        allowFiltering: false, //禁止过滤
        allowEditing: false, //禁用对特定列的编辑
        width: ScreenUtil().setWidth(40),
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: const Text(
            '序号',
            overflow: TextOverflow.clip,
            softWrap: true,
          ),
        ),
      ),
      GridColumn(
        columnName: 'goodscode',
        allowEditing: false, //禁用对特定列的编辑
        width: ScreenUtil().setWidth(90),
        filterPopupMenuOptions: const FilterPopupMenuOptions(
          // canShowSortingOptions: false, //隐藏排序选项
          // canShowClearFilterOption: false, //隐藏清除过滤器选项
          showColumnName: false, //从“清除过滤器”选项中隐藏列名称
        ),
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerLeft,
          child: const Text(
            '编码',
            overflow: TextOverflow.clip,
            softWrap: true,
          ),
        ),
      ),
      GridColumn(
        columnName: 'goodsname',
        allowEditing: false, //禁用对特定列的编辑
        width: ScreenUtil().setWidth(150),
        filterPopupMenuOptions: const FilterPopupMenuOptions(
          // canShowSortingOptions: false, //隐藏排序选项
          // canShowClearFilterOption: false, //隐藏清除过滤器选项
          showColumnName: false, //从“清除过滤器”选项中隐藏列名称
        ),
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerLeft,
          child: const Text(
            '商品名称',
            overflow: TextOverflow.clip,
            softWrap: true,
          ),
        ),
      ),
      GridColumn(
        columnName: 'amount',
        width: ScreenUtil().setWidth(70),
        allowSorting: false,
        filterPopupMenuOptions: const FilterPopupMenuOptions(
          canShowSortingOptions: false, //隐藏排序选项
          // canShowClearFilterOption: false, //隐藏清除过滤器选项
          showColumnName: false, //从“清除过滤器”选项中隐藏列名称
        ),
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerRight,
          child: const Text(
            '数量',
            overflow: TextOverflow.clip,
            softWrap: true,
          ),
        ),
      ),
    ]);
    return columns;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: const Text("实时盘点结果"),
        backgroundColor: Color.fromRGBO(86, 134, 219, 1),
      ),
      body: FutureBuilder(
          future: generateProductList(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            return snapshot.hasData
                ? SfDataGrid(
                    source: jsonDataGridSource,
                    selectionMode: SelectionMode.single, //选择行
                    allowSorting: true,
                    allowMultiColumnSorting: true,
                    allowTriStateSorting: true,
                    allowFiltering: true, //过滤选项
                    // allowEditing: true,
                    navigationMode: GridNavigationMode.cell,
                    // editingGestureType: EditingGestureType.doubleTap, //单击进入编辑
                    tableSummaryRows: [
                      //汇总合计行相关功能
                      GridTableSummaryRow(
                          // color: Colors.blue,
                          showSummaryInRow: false,
                          title: '统计:{Count}条盘点记录',
                          titleColumnSpan: 3,
                          columns: [
                            const GridSummaryColumn(
                              name: 'Count',
                              columnName: 'id',
                              summaryType: GridSummaryType.count,
                            ),
                            const GridSummaryColumn(
                                name: 'Sum',
                                columnName: 'amount',
                                summaryType: GridSummaryType.sum)
                          ],
                          position: GridTableSummaryRowPosition.bottom),
                    ],
                    columns: getColumns())
                : const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  );
          }),
    );
  }
}

class _Product {
  factory _Product.fromJson(Map<String, dynamic> json) {
    double amount = 0.0;
          String amountString = json['Amount'].toString();
String amountWithoutComma = amountString.replaceAll(",", "");
    try {

      amount =  double.parse(amountWithoutComma);
    } catch (e) {
      print('Erroramount: $e');
    }
    return _Product(
        ID: int.parse(json['id'].toString()), //接收解析数据
        goodscode: json['goodscode'],
        goodsname: json['goodsname'],
        amount:  double.parse(amountWithoutComma));
  }

  _Product( //包定义
      {
    this.ID,
    this.goodscode,
    this.goodsname,
    this.amount,
  });

  int? ID; //定义字段
  String? goodscode;
  String? goodsname;
  // ignore: non_constant_identifier_names
  double? amount;
}

class _JsonDataGridSource extends DataGridSource {
  _JsonDataGridSource(this.productlist) {
    buildDataGridRow();
  }
  dynamic newCellValue;
  TextEditingController editingController = TextEditingController();
  //禁止编辑
  @override
  bool onCellBeginEdit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex,
      GridColumn column) {
    if (column.columnName == 'id') {
      // Return false, to restrict entering into the editing.
      return false;
    } else {
      return true;
    }
  }

  // 可以提交单元格
  @override
  bool canSubmitCell(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex,
      GridColumn column) {
    if (column.columnName == 'id' && newCellValue == null) {
      // Return false, to retain in edit mode.
      // To avoid null value for cell
      return false;
    } else {
      return true;
    }
  }

// 在编辑完成时调用
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
      // print('编辑的值以更新' + newCellValue.toString());
      // print('更新的name:' + rowColumnIndex.columnIndex.toString());
      var ss = dataGridRows[dataRowIndex].getCells()[1].value;
      // print('获取商品编码：' + ss+);
      //以商品编码更新的盘点数量
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
        column.columnName == 'id' || column.columnName == 'amount';

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

// 按设定条件调整显示样式
  // style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      Color getColor() {
        if (dataGridCell.columnName == 'amount') {
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
        if (dataGridCell.columnName == 'amount') {
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
          alignment: (dataGridCell.columnName == 'Id' ||
                  dataGridCell.columnName == 'amount')
              ? Alignment.centerRight
              : Alignment.centerLeft,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
            style: getTextStyle(),
          ));
    }).toList());
  }

  List<DataGridRow> dataGridRows = [];
  List<_Product> productlist = [];

  void buildDataGridRow() {
    dataGridRows = productlist.map<DataGridRow>((dataGridRow) {
      return DataGridRow(cells: [
        DataGridCell<int>(
          columnName: 'ID',
          value: dataGridRow.ID,
        ),
        DataGridCell<String>(
          columnName: 'goodscode',
          value: dataGridRow.goodscode,
        ),
        DataGridCell<String>(
            columnName: 'goodsname', value: dataGridRow.goodsname),
        DataGridCell<double>(columnName: 'amount', value: dataGridRow.amount),
      ]);
    }).toList(growable: false);
  }

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
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
