import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './product_card.dart';
import '../../scoped_models/main.dart';
import '../../models/product.dart';

class Products extends StatelessWidget {

  Widget _buildConvinientWidget(List<Product> products) {
    Widget rendredWidget = Center(
      child: Text('No Food, please add some'),
    );
    if (products.length > 0) {
      rendredWidget = ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            ProductCard(products[index], index),
        itemCount: products.length,
      );
    }
    return rendredWidget;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return _buildConvinientWidget(model.displayedProducts);
      },
    );
//    products.length > 0
//        ? ListView.builder(
//            itemBuilder: _buildItems,
//            itemCount: products.length,
//          )
//        : Center(
//            child: Text('No Food'),
//          );
  }
}
