import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/page_wrapper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

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
            TextField(controller: current, obscureText: true, decoration: const InputDecoration(labelText: 'Current password')),
            const SizedBox(height: 12),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'New password')),
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to update password: $e')));
        }
      }
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
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
                            Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            SwitchListTile(
                              title: const Text('Dark mode'),
                              subtitle: const Text('Use a darker theme for low light and battery savings'),
                              value: settings.isDarkMode,
                              onChanged: (value) => settings.setDarkMode(value),
                            ),
                            const SizedBox(height: 16),
                            Text('Account', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            if (user != null) ...[
                              ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(user.name),
                                subtitle: Text(user.email),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => context.push('/settings/account'),
                              ),
                              ListTile(
                                leading: const Icon(Icons.lock),
                                title: const Text('Change password'),
                                subtitle: const Text('Keep your account secure'),
                                onTap: () => _showPasswordDialog(context),
                              ),
                              ListTile(
                                leading: const Icon(Icons.logout),
                                title: const Text('Sign out'),
                                onTap: () async {
                                  await auth.logout();
                                  if (!context.mounted) return;
                                  context.go('/home');
                                },
                              ),
                            ] else ...[
                              ListTile(
                                leading: const Icon(Icons.login),
                                title: const Text('Sign in to manage your account'),
                                onTap: () => context.push('/login'),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Text('Notifications', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            SwitchListTile(
                              title: const Text('Order updates'),
                              subtitle: const Text('Receive shipment, delivery, and order status alerts'),
                              value: settings.orderUpdates,
                              onChanged: settings.setOrderUpdates,
                            ),
                            SwitchListTile(
                              title: const Text('Promotions & discounts'),
                              subtitle: const Text('Get notified about sales, flash deals and special offers'),
                              value: settings.promotions,
                              onChanged: settings.setPromotions,
                            ),
                            SwitchListTile(
                              title: const Text('Messages & support'),
                              subtitle: const Text('Allow customer support updates in app notifications'),
                              value: settings.messages,
                              onChanged: settings.setMessages,
                            ),
                            const SizedBox(height: 16),
                            Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            ListTile(
                              leading: const Icon(Icons.location_on),
                              title: const Text('Saved shipping addresses'),
                              subtitle: const Text('Manage your favorite delivery addresses'),
                              trailing: const Text('Suggested', style: TextStyle(fontSize: 12)),
                              onTap: () => _showComingSoon('Saved addresses'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.credit_card),
                              title: const Text('Payment methods'),
                              subtitle: const Text('Store cards and mobile payment preferences'),
                              trailing: const Text('Suggested', style: TextStyle(fontSize: 12)),
                              onTap: () => _showComingSoon('Payment methods'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.language),
                              title: const Text('Language'),
                              subtitle: const Text('Switch between English and local languages'),
                              onTap: () => _showComingSoon('Language selection'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.attach_money),
                              title: const Text('Currency'),
                              subtitle: const Text('Set your preferred display currency'),
                              onTap: () => _showComingSoon('Currency preferences'),
                            ),
                            const SizedBox(height: 16),
                            Text('Support', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            ListTile(
                              leading: const Icon(Icons.privacy_tip),
                              title: const Text('Privacy & data'),
                              subtitle: const Text('Learn how your data is used and protected'),
                              onTap: () => _showComingSoon('Privacy & data'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.help_outline),
                              title: const Text('Help center'),
                              subtitle: const Text('Frequently asked questions and support'),
                              onTap: () => _showComingSoon('Help center'),
                            ),
                            const SizedBox(height: 16),
                            Text('Advanced', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                              'Advanced options for power users and diagnostics.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),
                            SwitchListTile(
                              title: const Text('Show welcome tips'),
                              subtitle: const Text('Display helpful walkthrough tips throughout the app'),
                              value: settings.showWelcomeTips,
                              onChanged: settings.setWelcomeTips,
                            ),
                            SwitchListTile(
                              title: const Text('Verbose debug logging'),
                              subtitle: const Text('Record extra diagnostic data for troubleshooting'),
                              value: settings.verboseLogging,
                              onChanged: settings.setVerboseLogging,
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
}
