import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/home_feed.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/page_wrapper.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  HomeFeed? _feed;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final feed = await context.read<AuthProvider>().api.getHome();
      if (mounted) {
        setState(() {
          _feed = feed;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Widget _productRow(List products) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final p = products[i];
          return SizedBox(
            width: 150,
            child: ProductCard(
              product: p,
              compact: true,
              onTap: () => context.push('/product/${p.id}'),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/MAIN LOGO 2.png',
          height: 36,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          if (auth.status != AuthStatus.authenticated)
            TextButton(
              onPressed: () => context.push('/login'),
              child: const Text('Sign in'),
            ),
        ],
      ),
      body: PageWrapper(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? ListView(
                      children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _load,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    children: [
                      if (auth.user != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.stars, color: Colors.amber),
                              title: Text('Hi, ${auth.user!.name}'),
                              subtitle: Text('${auth.user!.points} reward points'),
                            ),
                          ),
                        ),
                      const SectionHeader(title: 'Flash Sales'),
                      _productRow(_feed!.flashSales),
                      const SectionHeader(title: 'Recommended'),
                      _productRow(_feed!.recommended),
                      ..._feed!.categories.map((cat) {
                        final products = _feed!.categoryProducts[cat] ?? [];
                        if (products.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: cat,
                              onSeeAll: () => context.push(
                                '/category/${Uri.encodeComponent(cat)}',
                              ),
                            ),
                            _productRow(products),
                          ],
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  ),
      ),
        ),
    );
  }
}
