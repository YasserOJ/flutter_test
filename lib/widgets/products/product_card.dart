import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './price_widget.dart';
import '../ui_elements/title_default.dart';
import './adress_tag.dart';
import '../../models/product.dart';

import '../../scoped_models/main.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int index;

  ProductCard(this.product, this.index);

  Widget _buildTitlePriceRow() {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TitleDefault(
            product.title,
          ),
          SizedBox(
            width: 8,
          ),
          PriceWidget(product.price),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            color: Theme.of(context).accentColor,
            onPressed: () => Navigator.pushNamed<bool>(
                        context, '/product/${model.products[index].id}')
                    .then((value) {
                  if (!value) {
                    model.selectProduct(null);
                  }
                }),
          ),
          IconButton(
              icon: Icon(model.products[index].isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border),
              color: Colors.red,
              onPressed: () {
                model.selectProduct(model.products[index].id);
                model.toggleProductFavoriteStatus();
              })
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          FadeInImage(
            placeholder: AssetImage('assets/loading.gif'),
            image: NetworkImage(product.imageUrl),
            height: 300,
            fit: BoxFit.cover,
          ),
          _buildTitlePriceRow(),
          AdressTag(
            'Sahloul, Sousse',
          ),
          _buildActionButtons(context),
        ],
      ),
    );
  }
}
