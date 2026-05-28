import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Production Laravel API on Render (includes `/api` prefix).
  static const String productionBaseUrl =
      'https://cycle-jgso.onrender.com/api';

  /// Default base URL for the Laravel API (includes `/api` prefix).
  static String defaultBaseUrl() {
    // Release builds (APK / App Store) use Render.
    if (kReleaseMode) {
      return productionBaseUrl;
    }
    // Debug builds default to the deployed backend to support physical devices.
    return productionBaseUrl;
  }

  static const String baseUrlKey = 'api_base_url';
}
