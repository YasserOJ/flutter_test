import 'package:scoped_model/scoped_model.dart';

import './connectedProduct.dart';

class MainModel extends Model
    with UserModel, ProductsModel, ConnectedProductModel, UtilityModel {}
