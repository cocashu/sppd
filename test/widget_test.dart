void main() {
  String str = '123.12';
  double x = double.parse(str);

  var y = x.toInt();
  print(y);
  print(y.runtimeType);
}
