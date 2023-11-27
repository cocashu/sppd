import 'package:flutter/material.dart';

class QuantitySelector extends StatefulWidget {
  final int quantity;
  final Function(int) onQuantityChanged;

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
          icon: const Icon(Icons.remove),
          onPressed: () {
            setState(() {
              if (_quantity > 0) {
                _quantity--;
                widget.onQuantityChanged(_quantity);
              }
            });
          },
        ),
        Text('$_quantity'),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              _quantity++;
              widget.onQuantityChanged(_quantity);
            });
          },
        ),
      ],
    );
  }
}
