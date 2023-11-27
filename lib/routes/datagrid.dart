import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductCard extends StatefulWidget {
  const ProductCard({Key? key}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  var data;

  Future getData() async {
    var url = 'https://pd.chi-na.cn/app/kcgoodsapi.php?goodscode=010101002';
    var response = await http.get(url as Uri);

    setState(() {
      var extractData = json.decode(response.body);
      data = extractData['cards'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: FutureBuilder(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Text("Loading....");
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text('Name: ${data[index]['name']}'),
                      Text('Code: ${data[index]['code']}'),
                      Text('Barcode: ${data[index]['barcode']}'),
                      Text('Inventory: ${data[index]['inventory']}'),
                    ],
                  ));
                },
              );
            }
          }),
    );
  }
}
