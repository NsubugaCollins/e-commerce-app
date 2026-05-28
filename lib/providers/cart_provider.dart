import 'package:flutter/foundation.dart';

import '../models/cart.dart';
import '../services/campus_mall_api.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._api);

  final CampusMallApi _api;

  CartResponse? cart;
  bool loading = false;
  bool refreshing = false;
  String? error;

  int get itemCount => cart?.itemCount ?? 0;

  Future<void> load({bool backgroundRefresh = false}) async {
    if (cart != null && backgroundRefresh) {
      refreshing = true;
    } else {
      loading = true;
    }
    error = null;
    notifyListeners();
    try {
      final result = await _api.getCart();
      cart = result;
    } catch (e) {
      error = e.toString();
      if (cart == null) {
        cart = null;
      }
    }
    loading = false;
    refreshing = false;
    notifyListeners();
  }

  Future<bool> addProduct(int productId, {int quantity = 1}) async {
    try {
      await _api.addToCart(productId, quantity: quantity);
      await load(backgroundRefresh: true);
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    await _api.updateCartItem(cartItemId, quantity);
    await load(backgroundRefresh: true);
  }

  Future<void> removeItem(int cartItemId) async {
    await _api.removeCartItem(cartItemId);
    await load(backgroundRefresh: true);
  }

  void clear() {
    cart = null;
    notifyListeners();
  }
}
