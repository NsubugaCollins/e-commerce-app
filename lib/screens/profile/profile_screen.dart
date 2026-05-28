import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _shareToWhatsApp(String code) async {
    final message = Uri.encodeComponent(
        'Join Cycle using my referral link and get 20 bonus reward points! 🎁 https://campus-cylce.com/register?ref=$code');
    final url = Uri.parse('https://wa.me/?text=$message');
    if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // success
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  Future<void> _shareToTelegram(String code) async {
    final link = Uri.encodeComponent('https://campus-cylce.com/register?ref=$code');
    final message = Uri.encodeComponent('Join Cycle using my referral link and get 20 bonus reward points! 🎁');
    final url = Uri.parse('https://t.me/share/url?url=$link&text=$message');
    if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // success
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Telegram')),
        );
      }
    }
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
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Your referral code',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).cardColor.withValues(alpha: 0.5),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Theme.of(context).dividerColor),
                                              ),
                                              child: Text(
                                                user.referralCode,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton.filledTonal(
                                            icon: const Icon(Icons.copy),
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(text: user.referralCode));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Copied!')),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => _shareToWhatsApp(user.referralCode),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF25D366),
                                                foregroundColor: Colors.white,
                                              ),
                                              icon: const Icon(Icons.share),
                                              label: const Text('WhatsApp'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => _shareToTelegram(user.referralCode),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF229ED9),
                                                foregroundColor: Colors.white,
                                              ),
                                              icon: const Icon(Icons.telegram),
                                              label: const Text('Telegram'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
