import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/campus_mall_api.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _api = CampusMallApi(ApiClient());
  }

  late final CampusMallApi _api;
  CampusMallApi get api => _api;

  AuthStatus status = AuthStatus.unknown;
  User? user;
  String? error;

  bool get isAdmin => user?.isAdmin ?? false;
  bool get isShopper => user != null && !isAdmin;

  Future<void> bootstrap() async {
    try {
      user = await _api.getCurrentUser();
      status = AuthStatus.authenticated;
    } catch (_) {
      status = AuthStatus.unauthenticated;
      user = null;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    error = null;
    notifyListeners();
    try {
      final result = await _api.login(email, password);
      user = result.$1;
      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      error = ApiClient().parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? referralCode,
  }) async {
    error = null;
    notifyListeners();
    try {
      user = await _api.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        referralCode: referralCode,
      );
      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      error = ApiClient().parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      user = await _api.getCurrentUser();
      notifyListeners();
    } catch (_) {}
  }
}
