import 'package:dio/dio.dart';

import '../models/cart.dart';
import '../models/home_feed.dart';
import '../models/message.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../models/user_sale.dart';
import 'api_client.dart';

class CampusMallApi {
  CampusMallApi(this._client);
  final ApiClient _client;

  // ─── Auth ───
  Future<(User user, String token)> login(String email, String password) async {
    final res = await _client.post<Map<String, dynamic>>('/login', data: {
      'email': email,
      'password': password,
    });
    final token = res.data!['token'] as String;
    final user = User.fromJson(res.data!['user'] as Map<String, dynamic>);
    await _client.saveToken(token);
    return (user, token);
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? referralCode,
  }) async {
    final res = await _client.post<Map<String, dynamic>>('/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      if (phone != null) 'phone': phone,
      if (referralCode != null && referralCode.isNotEmpty)
        'referral_code': referralCode,
    });
    await _client.saveToken(res.data!['token'] as String);
    return User.fromJson(res.data!['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _client.post('/logout');
    } catch (_) {}
    await _client.clearToken();
  }

  Future<User> getCurrentUser() async {
    final res = await _client.get<Map<String, dynamic>>('/user');
    return User.fromJson(res.data!['user'] as Map<String, dynamic>);
  }

  // ─── Catalog ───
  Future<HomeFeed> getHome() async {
    final res = await _client.get<Map<String, dynamic>>('/home');
    return HomeFeed.fromJson(res.data!);
  }

  Future<List<String>> getCategories() async {
    final res = await _client.get<Map<String, dynamic>>('/categories');
    return (res.data!['categories'] as List).map((e) => e.toString()).toList();
  }

  Future<List<Product>> getProducts({String? search, String? category}) async {
    final res = await _client.get<Map<String, dynamic>>('/products', query: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null) 'category': category,
    });
    return (res.data!['data'] as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Product>> getCategoryProducts(String category) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/categories/${Uri.encodeComponent(category)}/products',
    );
    return (res.data!['data'] as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Product> getProduct(int id) async {
    final res = await _client.get<Map<String, dynamic>>('/products/$id');
    return Product.fromJson(res.data!['product'] as Map<String, dynamic>);
  }

  // ─── Cart & orders (user) ───
  Future<CartResponse> getCart() async {
    final res = await _client.get<Map<String, dynamic>>('/cart');
    return CartResponse.fromJson(res.data!);
  }

  Future<void> addToCart(int productId, {int quantity = 1}) async {
    await _client.post('/cart', data: {
      'product_id': productId,
      'quantity': quantity,
    });
  }

  Future<void> updateCartItem(int cartItemId, int quantity) async {
    await _client.patch('/cart/$cartItemId', data: {'quantity': quantity});
  }

  Future<void> removeCartItem(int cartItemId) async {
    await _client.delete('/cart/$cartItemId');
  }

  Future<List<OrderModel>> getOrders() async {
    final res = await _client.get<Map<String, dynamic>>('/orders');
    return (res.data!['orders'] as List)
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel> placeOrder({
    required String shippingAddress,
    required String paymentMethod,
    int pointsToUse = 0,
  }) async {
    final res = await _client.post<Map<String, dynamic>>('/orders', data: {
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
      'points_to_use': pointsToUse,
    });
    return OrderModel.fromJson(res.data!['order'] as Map<String, dynamic>);
  }

  Future<OrderModel> cancelOrder(int orderId) async {
    final res = await _client.post<Map<String, dynamic>>('/orders/$orderId/cancel');
    return OrderModel.fromJson(res.data!['order'] as Map<String, dynamic>);
  }

  Future<String> getPayPalApprovalUrl(int orderId) async {
    final res =
        await _client.post<Map<String, dynamic>>('/orders/$orderId/paypal');
    return res.data!['approval_url'] as String;
  }

  Future<void> submitRating({
    required int rating,
    String? comment,
    int? orderId,
  }) async {
    await _client.post('/ratings', data: {
      'rating': rating,
      if (comment != null) 'comment': comment,
      if (orderId != null) 'order_id': orderId,
    });
  }

  // ─── Profile (user) ───
  Future<Map<String, dynamic>> getProfile() async {
    final res = await _client.get<Map<String, dynamic>>('/profile');
    return res.data!;
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    await _client.put('/profile', data: {
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
    });
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String password,
  }) async {
    await _client.put('/profile/password', data: {
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': password,
    });
  }

  // ─── Messages (user ↔ admin) ───
  Future<({List<ChatMessage> messages, int adminId})> getUserMessages() async {
    final res = await _client.get<Map<String, dynamic>>('/messages');
    final list = res.data!['messages'] as List;
    final admin = res.data!['admin'] as Map<String, dynamic>;
    return (
      messages: list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      adminId: admin['id'] as int,
    );
  }

  Future<void> sendUserMessage({
    String? message,
    int? replyToId,
    String? filePath,
  }) async {
    if (filePath != null) {
      final form = FormData.fromMap({
        if (message != null && message.isNotEmpty) 'message': message,
        if (replyToId != null) 'reply_to_id': replyToId,
        'file': await MultipartFile.fromFile(filePath),
      });
      await _client.postMultipart('/messages', form);
    } else {
      await _client.post('/messages', data: {
        'message': message,
        if (replyToId != null) 'reply_to_id': replyToId,
      });
    }
  }

  Future<void> reactToMessage(int messageId, String reaction) async {
    await _client.post('/messages/$messageId/react', data: {'reaction': reaction});
  }

  // ─── Trade-in (user) ───
  Future<List<String>> getTradeInCategories() async {
    final res = await _client.get<Map<String, dynamic>>('/trade-in/categories');
    return (res.data!['categories'] as List).map((e) => e.toString()).toList();
  }

  Future<List<UserSaleModel>> getMyTradeIns() async {
    final res = await _client.get<Map<String, dynamic>>('/trade-in');
    return (res.data!['data'] as List)
        .map((e) => UserSaleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UserSaleModel> getTradeIn(int id) async {
    final res = await _client.get<Map<String, dynamic>>('/trade-in/$id');
    return UserSaleModel.fromJson(res.data!['sale'] as Map<String, dynamic>);
  }

  Future<UserSaleModel> createTradeIn({
    required String productName,
    required String category,
    required String condition,
    required String description,
    required double expectedPrice,
    required List<String> imagePaths,
  }) async {
    final form = FormData.fromMap({
      'product_name': productName,
      'category': category,
      'condition': condition,
      'description': description,
      'expected_price': expectedPrice,
    });
    for (final path in imagePaths) {
      form.files.add(MapEntry(
        'images[]',
        await MultipartFile.fromFile(path),
      ));
    }
    final res = await _client.postMultipart<Map<String, dynamic>>('/trade-in', form);
    return UserSaleModel.fromJson(res.data!['sale'] as Map<String, dynamic>);
  }

  Future<void> acceptTradeInOffer(int id) async {
    await _client.post('/trade-in/$id/accept');
  }

  Future<void> rejectTradeInOffer(int id) async {
    await _client.post('/trade-in/$id/reject');
  }

  Future<void> deleteTradeIn(int id) async {
    await _client.delete('/trade-in/$id');
  }

  // ─── Admin ───
  Future<Map<String, dynamic>> adminDashboard() async {
    final res = await _client.get<Map<String, dynamic>>('/admin/dashboard');
    return res.data!;
  }

  Future<Map<String, dynamic>> adminAnalytics() async {
    final res = await _client.get<Map<String, dynamic>>('/admin/analytics');
    return res.data!;
  }

  Future<Map<String, dynamic>> adminEarnings() async {
    final res = await _client.get<Map<String, dynamic>>('/admin/earnings');
    return res.data!;
  }

  Future<List<Product>> adminProducts() async {
    final res = await _client.get<Map<String, dynamic>>('/admin/products');
    return (res.data!['data'] as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Product> adminProduct(int id) async {
    final res = await _client.get<Map<String, dynamic>>('/admin/products/$id');
    return Product.fromJson(res.data!['product'] as Map<String, dynamic>);
  }

  Future<void> adminDeleteProduct(int id) async {
    await _client.delete('/admin/products/$id');
  }

  Future<void> adminDeleteProductImage(int imageId) async {
    await _client.delete('/admin/product-images/$imageId');
  }

  Future<List<Map<String, dynamic>>> adminOrders() async {
    final res = await _client.get<Map<String, dynamic>>('/admin/orders');
    return (res.data!['data'] as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> adminOrder(int id) async {
    final res = await _client.get<Map<String, dynamic>>('/admin/orders/$id');
    return res.data!['order'] as Map<String, dynamic>;
  }

  Future<void> adminUpdateOrderStatus(int id, String status) async {
    await _client.patch('/admin/orders/$id/status', data: {'status': status});
  }

  Future<List<Map<String, dynamic>>> adminUsers() async {
    final res = await _client.get<Map<String, dynamic>>('/admin/users');
    return (res.data!['users'] as List).cast<Map<String, dynamic>>();
  }

  Future<void> adminDeleteUser(int id) async {
    await _client.delete('/admin/users/$id');
  }

  Future<List<MessageThread>> adminMessageThreads() async {
    final res = await _client.get<Map<String, dynamic>>('/admin/messages/threads');
    return (res.data!['threads'] as List)
        .map((e) => MessageThread.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<({MessageThread user, List<ChatMessage> messages})> adminChatWith(
      int userId) async {
    final res = await _client.get<Map<String, dynamic>>('/admin/messages/$userId');
    final userJson = res.data!['user'] as Map<String, dynamic>;
    final list = res.data!['messages'] as List;
    return (
      user: MessageThread(
        id: userJson['id'] as int,
        name: userJson['name'] as String,
        email: userJson['email'] as String,
        unreadCount: 0,
      ),
      messages: list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> adminSendMessage(int userId,
      {String? message, String? filePath}) async {
    if (filePath != null) {
      final form = FormData.fromMap({
        if (message != null) 'message': message,
        'file': await MultipartFile.fromFile(filePath),
      });
      await _client.postMultipart('/admin/messages/$userId', form);
    } else {
      await _client.post('/admin/messages/$userId', data: {'message': message});
    }
  }

  Future<List<UserSaleModel>> adminTradeIns() async {
    final res = await _client.get<Map<String, dynamic>>('/admin/trade-in');
    return (res.data!['data'] as List)
        .map((e) => UserSaleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UserSaleModel> adminTradeIn(int id) async {
    final res = await _client.get<Map<String, dynamic>>('/admin/trade-in/$id');
    return UserSaleModel.fromJson(res.data!['sale'] as Map<String, dynamic>);
  }

  Future<void> adminMakeOffer(int id, double price, {String? notes}) async {
    await _client.patch('/admin/trade-in/$id/offer', data: {
      'offered_price': price,
      if (notes != null) 'admin_notes': notes,
    });
  }

  Future<void> adminUpdateTradeInStatus(int id, String status,
      {String? notes}) async {
    await _client.patch('/admin/trade-in/$id/status', data: {
      'status': status,
      if (notes != null) 'admin_notes': notes,
    });
  }

  Future<Map<String, dynamic>> adminSettings() async {
    final res = await _client.get<Map<String, dynamic>>('/admin/settings');
    return Map<String, dynamic>.from(res.data!['settings'] as Map);
  }

  Future<void> adminUpdateSettings(Map<String, dynamic> settings) async {
    await _client.put('/admin/settings', data: settings);
  }

  Future<void> adminUpdateProfile({
    required String name,
    required String email,
    String? password,
  }) async {
    await _client.put('/admin/profile', data: {
      'name': name,
      'email': email,
      if (password != null) ...{
        'password': password,
        'password_confirmation': password,
      },
    });
  }

  Future<Product> adminCreateProduct(FormData form) async {
    final res =
        await _client.postMultipart<Map<String, dynamic>>('/admin/products', form);
    return Product.fromJson(res.data!['product'] as Map<String, dynamic>);
  }

  Future<Product> adminUpdateProduct(int id, FormData form) async {
    final res = await _client
        .postMultipart<Map<String, dynamic>>('/admin/products/$id', form);
    return Product.fromJson(res.data!['product'] as Map<String, dynamic>);
  }
}
