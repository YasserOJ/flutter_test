import 'package:flutter/material.dart';

class PriceWidget extends StatelessWidget {

  final double _price;

  PriceWidget(this._price);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '\$ $_price',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
