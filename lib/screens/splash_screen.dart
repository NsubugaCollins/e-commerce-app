import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();
    try {
      // Use a timeout so the splash never hangs forever on bad networks.
      await auth.bootstrap().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          // Treat a timeout the same as unauthenticated; the user can log in.
        },
      );
    } catch (_) {
      // Any unexpected error during bootstrap is treated as unauthenticated.
    }
    if (!mounted) return;
    if (auth.status == AuthStatus.authenticated) {
      context.go(auth.isAdmin ? '/admin' : '/home');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/MAIN LOGO 2.png',
              height: 120,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
