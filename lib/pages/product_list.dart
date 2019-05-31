import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './product_edit.dart';
import '../scoped_models/main.dart';

class ProductListPage extends StatefulWidget {
  final MainModel model;

  ProductListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ProductListPageState();
  }
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    widget.model.fetchProducts(onlyForUsers: true);
  }

  Widget _buildEditButton(BuildContext context, int index, MainModel model) {
    return IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          model.selectProduct(model.products[index].id);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return ProductEditPage();
              },
            ),
          ).then((_){
            model.selectProduct(null);
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
                onDismissed: (DismissDirection direction) {
                  model.selectProduct(model.products[index].id  );
                  model.deleteProduct();
                },
                background: Container(
                  child: Center(
                    child: Text('delete'),
                  ),
                  color: Colors.red,
                ),
                key: Key(model.products[index].title),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(model.products[index].imageUrl),
                      ),
                      title: Text(model.products[index].title),
                      subtitle: Text('\$${model.products[index].price}'),
                      trailing: _buildEditButton(context, index, model),
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                  ],
                ));
          },
          itemCount: model.products.length,
        );
      },
    );
  }
}
