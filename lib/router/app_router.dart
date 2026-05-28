import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/admin/admin_chat_screen.dart';
import '../screens/admin/admin_profile_screen.dart';
import '../screens/admin/admin_shell.dart';
import '../screens/admin/analytics_screen.dart';
import '../screens/admin/dashboard_screen.dart';
import '../screens/admin/earnings_screen.dart';
import '../screens/admin/messages_screen.dart';
import '../screens/admin/order_detail_screen.dart';
import '../screens/admin/orders_screen.dart';
import '../screens/admin/product_form_screen.dart';
import '../screens/admin/products_screen.dart';
import '../screens/admin/settings_screen.dart';
import '../screens/admin/trade_in_detail_screen.dart';
import '../screens/admin/trade_in_screen.dart';
import '../screens/admin/users_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/cart/checkout_screen.dart';
import '../screens/home/category_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/product_detail_screen.dart';
import '../screens/home/search_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/account_settings_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/shell/main_shell.dart';
import '../screens/splash_screen.dart';
import '../screens/user/messages_screen.dart';
import '../screens/user/trade_in_create_screen.dart';
import '../screens/user/trade_in_detail_screen.dart';
import '../screens/user/trade_in_list_screen.dart';

class AppRouter {
  static GoRouter create(AuthProvider auth) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: auth,
      redirect: (context, state) {
        final loc = state.matchedLocation;
        final isAuth = auth.status == AuthStatus.authenticated;
        final isAdmin = auth.isAdmin;
        final isAdminRoute = loc.startsWith('/admin');
        final isUserRoute = !isAdminRoute &&
            !loc.startsWith('/login') &&
            !loc.startsWith('/register') &&
            loc != '/splash';

        if (auth.status == AuthStatus.unknown) {
          return loc == '/splash' ? null : '/splash';
        }

        if (isAuth && isAdmin && !isAdminRoute && loc != '/splash') {
          return '/admin';
        }

        if (isAuth && !isAdmin && isAdminRoute) {
          return '/home';
        }

        if (!isAuth && (loc == '/cart' || loc == '/checkout' || loc == '/orders' ||
            loc == '/profile' || loc == '/messages' || loc.startsWith('/sell'))) {
          return '/login';
        }

        if (isAuth && (loc == '/login' || loc == '/register')) {
          return isAdmin ? '/admin' : '/home';
        }

        final guestOk = loc == '/login' ||
            loc == '/register' ||
            loc == '/splash' ||
            loc.startsWith('/home') ||
            loc.startsWith('/product') ||
            loc.startsWith('/category') ||
            loc == '/search';

        if (!isAuth && !guestOk && isUserRoute) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        ShellRoute(
          builder: (_, __, child) => MainShell(child: child),
          routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
            GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
            GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
            GoRoute(path: '/messages', builder: (_, __) => const MessagesScreen()),
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ],
        ),
        ShellRoute(
          builder: (_, __, child) => AdminShell(child: child),
          routes: [
            GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
            GoRoute(path: '/admin/products', builder: (_, __) => const AdminProductsScreen()),
            GoRoute(path: '/admin/orders', builder: (_, __) => const AdminOrdersScreen()),
            GoRoute(path: '/admin/users', builder: (_, __) => const AdminUsersScreen()),
            GoRoute(path: '/admin/messages', builder: (_, __) => const AdminMessagesScreen()),
            GoRoute(path: '/admin/trade-in', builder: (_, __) => const AdminTradeInScreen()),
          ],
        ),
        GoRoute(path: '/product/:id', builder: (_, s) => ProductDetailScreen(productId: int.parse(s.pathParameters['id']!))),
        GoRoute(path: '/category/:name', builder: (_, s) => CategoryScreen(category: Uri.decodeComponent(s.pathParameters['name']!))),
        GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
        GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(path: '/settings/account', builder: (_, __) => const AccountSettingsScreen()),
        GoRoute(path: '/sell', builder: (_, __) => const TradeInListScreen()),
        GoRoute(path: '/sell/create', builder: (_, __) => const TradeInCreateScreen()),
        GoRoute(path: '/sell/:id', builder: (_, s) => TradeInDetailScreen(saleId: int.parse(s.pathParameters['id']!))),
        GoRoute(path: '/admin/products/new', builder: (_, __) => const AdminProductFormScreen()),
        GoRoute(path: '/admin/products/:id', builder: (_, s) => AdminProductFormScreen(productId: int.parse(s.pathParameters['id']!))),
        GoRoute(path: '/admin/orders/:id', builder: (_, s) => AdminOrderDetailScreen(orderId: int.parse(s.pathParameters['id']!))),
        GoRoute(path: '/admin/messages/:userId', builder: (_, s) => AdminChatScreen(userId: int.parse(s.pathParameters['userId']!))),
        GoRoute(path: '/admin/trade-in/:id', builder: (_, s) => AdminTradeInDetailScreen(saleId: int.parse(s.pathParameters['id']!))),
        GoRoute(path: '/admin/analytics', builder: (_, __) => const AdminAnalyticsScreen()),
        GoRoute(path: '/admin/earnings', builder: (_, __) => const AdminEarningsScreen()),
        GoRoute(path: '/admin/settings', builder: (_, __) => const AdminSettingsScreen()),
        GoRoute(path: '/admin/profile', builder: (_, __) => const AdminProfileScreen()),
      ],
    );
  }
}
