import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Production Laravel API on www.campus-cylce.com (includes `/api` prefix).
  /// NOTE: campus-cylce.com (no www) issues a 307 redirect to www, which can
  /// silently break POST requests on Android. Always target www directly.
  static const String productionBaseUrl =
      'https://www.campus-cylce.com/api';

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
