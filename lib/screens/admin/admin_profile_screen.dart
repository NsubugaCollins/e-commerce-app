import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/page_wrapper.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    final u = context.read<AuthProvider>().user;
    if (u != null) {
      _name.text = u.name;
      _email.text = u.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin profile')),
      body: PageWrapper(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'New password (optional)')),
          ElevatedButton(
            onPressed: () async {
              await context.read<AuthProvider>().api.adminUpdateProfile(
                    name: _name.text,
                    email: _email.text,
                    password: _password.text.isEmpty ? null : _password.text,
                  );
              await context.read<AuthProvider>().refreshUser();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated')));
              }
            },
            child: const Text('Save'),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              context.read<CartProvider>().clear();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
        ),
    );
  }
}
