class Globals {
  // Environment detection
  static bool get isWeb => identical(0, 0.0); // Simple web detection

  // Configuration constants
  static const String _devBaseUrl = "https://aripsalin.elkedeseen.com";

  // Base URL configuration
  static String get baseUrl {
    // Check for environment variable first
    const String envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envBaseUrl.isNotEmpty) {
      return envBaseUrl;
    }

    // For web production (when served over HTTPS), use relative URLs
    // This will work with Netlify redirects
    if (isWeb && Uri.base.scheme == 'https') {
      return ""; // Use relative URLs for production (Netlify will proxy)
    }

    // For development or HTTP environments
    return _devBaseUrl;
  }

  // Helper method to get the appropriate URL based on current context
  static String getApiUrl(String endpoint) {
    if (baseUrl.isEmpty) {
      // For production with Netlify redirects, use relative URLs
      return endpoint.startsWith('/') ? endpoint : '/$endpoint';
    }
    return '$baseUrl$endpoint';
  }

  // Debug information
  static Map<String, dynamic> get debugInfo => {
    'isWeb': isWeb,
    'currentScheme': isWeb ? Uri.base.scheme : 'native',
    'baseUrl': baseUrl.isEmpty ? 'relative (proxied)' : baseUrl,
    'currentHost': isWeb ? Uri.base.host : 'native',
  };
}