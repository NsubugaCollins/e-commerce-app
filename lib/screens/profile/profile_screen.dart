import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/page_wrapper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await context.read<AuthProvider>().api.getProfile();
      if (mounted) {
        setState(() {
          _profile = data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : PageWrapper(
              child: LayoutBuilder(
                builder: (context, constraints) => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (user != null) ...[
                              ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.person)),
                                title: Text(user.name),
                                subtitle: Text(user.email),
                              ),
                              const SizedBox(height: 12),
                              Card(
                                child: ListTile(
                                  leading: const Icon(Icons.stars, color: Colors.amber),
                                  title: Text('${user.points} points'),
                                  subtitle: const Text('100 pts = UGX 1,000 off at checkout'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Card(
                                child: ListTile(
                                  title: const Text('Your referral code'),
                                  subtitle: Text(user.referralCode),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: user.referralCode));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Copied!')),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                            if (_profile != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Stats',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      _statRow(
                                        'Total orders',
                                        '${_profile!['stats']['total_orders']}',
                                      ),
                                      _statRow(
                                        'Completed',
                                        '${_profile!['stats']['completed_orders']}',
                                      ),
                                      _statRow(
                                        'Total spent',
                                        'UGX ${_profile!['stats']['total_spent']}',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            ListTile(
                              leading: const Icon(Icons.sell),
                              title: const Text('Trade-in / Sell'),
                              onTap: () => context.push('/sell'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.lock),
                              title: const Text('Change password'),
                              onTap: () => _showPasswordDialog(context),
                            ),
                            const SizedBox(height: 24),
                            OutlinedButton(
                              onPressed: () async {
                                await auth.logout();
                                if (!context.mounted) return;
                                context.read<CartProvider>().clear();
                                context.go('/home');
                              },
                              child: const Text('Sign out'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ),
          ),
        ),
    );
  }

  Future<void> _showPasswordDialog(BuildContext context) async {
    final current = TextEditingController();
    final password = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: current, obscureText: true, decoration: const InputDecoration(labelText: 'Current')),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'New')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      try {
        await context.read<AuthProvider>().api.updatePassword(
              currentPassword: current.text,
              password: password.text,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
        }
      }
    }
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))],
      ),
    );
  }
}
