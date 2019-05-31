import 'dart:convert';
import 'dart:async';

import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';

import '../models/product.dart';
import '../models/user.dart';
import '../models/auth.dart';

class ConnectedProductModel extends Model {
  List<Product> _products = [];
  String _selectedProductId;
  User _authenticatedUser;
  bool _isLoading = false;
}

class ProductsModel extends ConnectedProductModel {
  bool _showFavorites = false;

  List<Product> get products => List.from(_products);

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return _products.where((Product product) {
        return product.isFavorite;
      }).toList();
    }
    return List.from(_products);
  }

  String get selectedProductId => _selectedProductId;

  bool get showFavorites => _showFavorites;

  Product get selectedProduct {
    if (_selectedProductId == null) {
      return null;
    }
    return _products.firstWhere((Product product) {
      return product.id == _selectedProductId;
    });
  }

  int get selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.id == selectedProductId;
    });
  }

  Future<Null> fetchProducts({bool onlyForUsers = false}) {
    _isLoading = true;
    notifyListeners();
    return http
        .get(
            'https://test-66f28.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
      Map<String, dynamic> productListData = json.decode(response.body);
      final List<Product> fetchedProductsList = [];
      if (productListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      productListData.forEach((String key, dynamic productData) {
        final product = Product(
            id: key,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            imageUrl: productData['image'],
            userEmail: productData['userEmail'],
            userId: productData['userId'],
            isFavorite: productData['wishlistUsers'] == null
                ? false
                : (productData['wishlistUsers'] as Map<String, dynamic>)
                    .containsKey(_authenticatedUser.id));
        fetchedProductsList.add(product);
      });
      _products = onlyForUsers == false
          ? fetchedProductsList
          : fetchedProductsList.where((Product product) {
              return product.userId == _authenticatedUser.id;
            }).toList();
      _isLoading = false;
      notifyListeners();
      _selectedProductId = null;
      return;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

  Future<bool> addProduct(
      String title, String description, String image, double price) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'https://cdn11.bigcommerce.com/s-ham8sjk/products/274/images/774/couverture_chocolate_milk_chocolate__92101.1515385422.600.600.jpg?c=2',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id
    };
    try {
      final http.Response response = await http.post(
          'https://test-66f28.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
          body: json.encode(productData));
      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responsebody = json.decode(response.body);
      final Product newProduct = Product(
          id: responsebody['name'],
          title: title,
          description: description,
          price: price,
          imageUrl: image,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);
      _products.add(newProduct);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(
      String title, String description, String image, double price) {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'image':
          'https://cdn11.bigcommerce.com/s-ham8sjk/products/274/images/774/couverture_chocolate_milk_chocolate__92101.1515385422.600.600.jpg?c=2',
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId
    };
    return http
        .put(
            'https://test-66f28.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
            body: json.encode(updateData))
        .then((http.Response response) {
      final Product newProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          price: price,
          imageUrl: image,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);
      _products[selectedProductIndex] = newProduct;
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> deleteProduct() {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selectedProductId = null;
    notifyListeners();
    return http
        .delete(
            'https://test-66f28.firebaseio.com/products/$deletedProductId.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  void toggleProductFavoriteStatus() async {
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;
    final bool newFavoriteState = !isCurrentlyFavorite;
    http.Response response;
    final Product product = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        imageUrl: selectedProduct.imageUrl,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavorite: newFavoriteState);
    _products[selectedProductIndex] = product;
    notifyListeners();
    if (newFavoriteState) {
      response = await http.put(
          'https://test-66f28.firebaseio.com/products/${selectedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(true));
    } else {
      response = await http.delete(
          'https://test-66f28.firebaseio.com/products/${selectedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Product product = Product(
          id: selectedProduct.id,
          title: selectedProduct.title,
          description: selectedProduct.description,
          price: selectedProduct.price,
          imageUrl: selectedProduct.imageUrl,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId,
          isFavorite: !newFavoriteState);
      _products[selectedProductIndex] = product;
      notifyListeners();
    }
    _selectedProductId = null;
    selectProduct(null);
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }

  void selectProduct(String productId) {
    _selectedProductId = productId;
    notifyListeners();
  }
}

class UserModel extends ConnectedProductModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  User get user => _authenticatedUser;

  PublishSubject<bool> get userSubject => _userSubject;

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode authMode = AuthMode.LogIn]) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response;
    if (authMode == AuthMode.LogIn) {
      response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyCQGW7YLW8HWbM1zUpVInif52kcjw0JcKY',
          body: json.encode(authData),
          headers: {'Content-Type': 'application/json'});
    } else {
      response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyCQGW7YLW8HWbM1zUpVInif52kcjw0JcKY',
          body: json.encode(authData),
          headers: {'Content-Type': 'application/json'});
    }
    final Map<String, dynamic> responseBody = json.decode(response.body);
    print(responseBody);
    bool hasError = true;
    String message = 'Something Went Wrong!';
    if (responseBody.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication successed!';
      User user = User(
          id: responseBody['localId'],
          email: email,
          token: responseBody['idToken']);
      _authenticatedUser = user;
      setAuthTimeout(int.parse(responseBody['expiresIn']));
      _userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseBody['expiresIn'])));
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString('token', responseBody['idToken']);
      sharedPreferences.setString('userEmail', email);
      sharedPreferences.setString('userId', responseBody['localId']);
      sharedPreferences.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseBody['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'this email already was not found';
    } else if (responseBody['error']['message'] == 'INVALID_PASSWORD') {
      message = 'this password is invalid';
    } else if (responseBody['error']['message'] == 'EMAIL_EXISTS') {
      message = 'this email already exists';
    }
    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void autoAuthenticate() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final String token = sharedPreferences.get('token');
    final String expiryTimeString = sharedPreferences.get('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final DateTime parsedExpiryTime = DateTime.parse(expiryTimeString);
      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        _userSubject.add(false);
        notifyListeners();
        return;
      }
      final String userEmail = sharedPreferences.get('userEmail');
      final String userId = sharedPreferences.get('userId');
      final int tokenLifeSpan = parsedExpiryTime.difference(now).inSeconds;
      User user = User(id: userId, email: userEmail, token: token);
      _authenticatedUser = user;
      _userSubject.add(true);
      setAuthTimeout(tokenLifeSpan);
      notifyListeners();
    }
  }

  void logout() async {
    _authenticatedUser = null;
    _authTimer.cancel();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.remove('token');
    sharedPreferences.remove('userEmail');
    sharedPreferences.remove('userId');
    _userSubject.add(false);
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}

class UtilityModel extends ConnectedProductModel {
  bool get isLoading => _isLoading;
}
