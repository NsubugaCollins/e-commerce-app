import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/page_wrapper.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _users = await context.read<AuthProvider>().api.adminUsers();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: PageWrapper(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, i) {
                  final u = _users[i];
                  return ListTile(
                    title: Text(u['name'] as String),
                    subtitle: Text('${u['email']} · ${u['points']} pts'),
                    trailing: IconButton(
                      icon: const Icon(Icons.block),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete user?'),
                            content: const Text('User will be blacklisted.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await context.read<AuthProvider>().api.adminDeleteUser(u['id'] as int);
                          _load();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
        ),
    );
  }
}
