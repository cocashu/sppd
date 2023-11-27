import 'package:flutter/material.dart';

class QuantitySelector extends StatefulWidget {
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  QuantitySelector({required this.quantity, required this.onQuantityChanged});

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  int _quantity = 0;

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () {
            if (_quantity > 0) {
              setState(() {
                _quantity--;
                widget.onQuantityChanged(_quantity);
              });
            }
          },
        ),
        SizedBox(
          width: 40,
          child: Text(
            '$_quantity',
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            setState(() {
              _quantity = _quantity + 10;
              widget.onQuantityChanged(_quantity);
            });
          },
        ),
      ],
    );
  }
}
