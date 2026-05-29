import 'package:flutter/foundation.dart';
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

  // Catch Flutter framework errors (e.g. layout overflows, widget exceptions)
  // and log them instead of crashing the app.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // In release builds swallow non-fatal framework errors gracefully.
    }
  };

  // Catch async errors that escape the Flutter framework (e.g. isolate errors).
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught platform error: $error');
    return true; // returning true marks the error as handled.
  };

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
    // NOTE: bootstrap() is intentionally NOT called here.
    // SplashScreen is the single place that calls bootstrap() so there is
    // only ever one concurrent auth check.  Calling it here AND in
    // SplashScreen caused two simultaneous notifyListeners() calls which
    // triggered GoRouter's redirect-cycle assertion and crashed the app.
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
          title: 'Cycle',
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
