import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../scoped_models/main.dart';

class LogoutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model){
      return ListTile(
        leading: Icon(Icons.exit_to_app),
        title: Text('logout'),
        onTap: () {
          model.logout();
//          Navigator.of(context).pushReplacementNamed('/');
        },
      );
    },);
  }
}
