import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _indexFromLocation(String location) {
    if (location.startsWith('/cart')) return 1;
    if (location.startsWith('/orders')) return 2;
    if (location.startsWith('/messages')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();
    if (auth.status == AuthStatus.authenticated && cartProvider.cart == null) {
      cartProvider.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(location);
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/home');
            case 1:
              if (auth.status != AuthStatus.authenticated) {
                context.push('/login');
              } else {
                context.go('/cart');
              }
            case 2:
              if (auth.status != AuthStatus.authenticated) {
                context.push('/login');
              } else {
                context.go('/orders');
              }
            case 3:
              if (auth.status != AuthStatus.authenticated) {
                context.push('/login');
              } else {
                context.go('/messages');
              }
            case 4:
              if (auth.status != AuthStatus.authenticated) {
                context.push('/login');
              } else {
                context.go('/profile');
              }
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cart.itemCount > 0,
              label: Text('${cart.itemCount}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: const Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          const NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
