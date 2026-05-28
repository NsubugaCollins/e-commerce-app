import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  int _index(String loc) {
    if (loc.startsWith('/admin/products')) return 1;
    if (loc.startsWith('/admin/orders')) return 2;
    if (loc.startsWith('/admin/users')) return 3;
    if (loc.startsWith('/admin/messages')) return 4;
    if (loc.startsWith('/admin/trade-in')) return 5;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final index = _index(loc);

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Cycle Admin')),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Analytics'),
              onTap: () {
                Navigator.pop(context);
                context.push('/admin/analytics');
              },
            ),
            ListTile(
              leading: const Icon(Icons.payments),
              title: const Text('Earnings'),
              onTap: () {
                Navigator.pop(context);
                context.push('/admin/earnings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                context.push('/admin/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                context.push('/admin/profile');
              },
            ),
          ],
        ),
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/admin');
            case 1:
              context.go('/admin/products');
            case 2:
              context.go('/admin/orders');
            case 3:
              context.go('/admin/users');
            case 4:
              context.go('/admin/messages');
            case 5:
              context.go('/admin/trade-in');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.receipt), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Users'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.sell), label: 'Trade-in'),
        ],
      ),
    );
  }
}
