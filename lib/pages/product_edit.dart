import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';
import '../scoped_models/main.dart';

class ProductEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': 'assets/food.jpg'
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildTitleTextField(Product product) {
    return TextFormField(
      initialValue: product == null ? '' : product.title,
      validator: (String value) {
        if (value.isEmpty) {
          return 'title is required';
        }
        if (value.length < 5) {
          return 'title should be 5 character minimum';
        }
      },
      decoration:
          InputDecoration(hintText: 'Title', labelText: 'Product Title'),
      onSaved: (String value) {
        _formData['title'] = value;
      },
    );
  }

  Widget _buildDescriptionTextField(Product product) {
    return TextFormField(
      initialValue: product == null ? '' : product.description,
      validator: (String value) {
        if (value.isEmpty) {
          return 'description is required';
        }
      },
      decoration: InputDecoration(labelText: 'Product description'),
      maxLines: 5,
      onSaved: (String value) {
        _formData['description'] = value;
      },
    );
  }

  Widget _buildPriceTextField(Product product) {
    return TextFormField(
      initialValue: product == null ? '' : product.price.toString(),
      validator: (String value) {
        if (value.isEmpty) {
          return 'price is required';
        }
        if (!RegExp(r'(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return 'price should be a number';
        }
      },
      decoration: InputDecoration(labelText: 'Product price'),
      keyboardType: TextInputType.number,
      onSaved: (String value) {
        _formData['price'] = double.parse(value);
      },
    );
  }

  Widget _buildRaisedButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RaisedButton(
                child: Text('SAVE'),
                color: Theme.of(context).accentColor,
                onPressed: () => _submitForm(
                    model.addProduct,
                    model.updateProduct,
                    model.selectProduct,
                    model.selectedProductIndex),
              );
      },
    );
  }

  Widget _buildGestureDetector(BuildContext context, Product product) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double targetWidth = screenWidth > 768 ? 700 : screenWidth * 0.95;
    final double padding = screenWidth - targetWidth;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: (padding / 2)),
            children: <Widget>[
              _buildTitleTextField(product),
              _buildDescriptionTextField(product),
              _buildPriceTextField(product),
              SizedBox(
                height: 10,
              ),
              _buildRaisedButton(),
//              GestureDetector(
//                onTap: _submitForm,
//                child: Container(
//                  color: Colors.green,
//                  padding: EdgeInsets.all(5),
//                  child: Center(
//                    child: Text('Click me'),
//                  ),
//                ),
//              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm(
      Function addProduct, Function updateProduct, Function setSelectedProduct,
      [int selectedProductIndex]) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (selectedProductIndex == -1) {
        addProduct(
          _formData['title'],
          _formData['description'],
          _formData['image'],
          _formData['price'],
        ).then((bool success) {
          if (success) {
            Navigator.pushReplacementNamed(context, '/products').then(
              (_) => setSelectedProduct(null),
            );
          } else {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Something went wrong'),
                    content: Text('please try again! '),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'))
                    ],
                  );
                });
          }
        });
      } else {
        updateProduct(
          _formData['title'],
          _formData['description'],
          _formData['image'],
          _formData['price'],
        ).then((_) {
          Navigator.pushReplacementNamed(context, '/products').then(
            (_) => setSelectedProduct(null),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget widgetToRender =
            _buildGestureDetector(context, model.selectedProduct);
        return model.selectedProductIndex == -1
            ? widgetToRender
            : Scaffold(
                appBar: AppBar(
                  title: Text('edit Product'),
                ),
                body: widgetToRender,
              );
      },
    );
  }
}
