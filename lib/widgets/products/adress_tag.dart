import 'package:flutter/material.dart';


class AdressTag extends StatelessWidget {

  final String address;

  AdressTag(this.address);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
        child: Text(address),
      ),
    );
  }

}