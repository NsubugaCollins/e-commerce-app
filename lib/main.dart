import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/settings_provider.dart';
import 'router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CampusMallApp());
}

class CampusMallApp extends StatefulWidget {
  const CampusMallApp({super.key});

  @override
  State<CampusMallApp> createState() => _CampusMallAppState();
}

class _CampusMallAppState extends State<CampusMallApp> {
  late final AuthProvider _authProvider;
  late final SettingsProvider _settingsProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _settingsProvider = SettingsProvider();
    _settingsProvider.load();
    _router = AppRouter.create(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _settingsProvider),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(_authProvider.api),
          update: (_, auth, cart) => cart ?? CartProvider(auth.api),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp.router(
          title: 'Campus Mall',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          routerConfig: _router,
        ),
      ),
    );
  }
}
