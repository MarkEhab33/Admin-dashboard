class Globals {

  // Environment detection
  static bool get isWeb => identical(0, 0.0); // Simple web detection

  // Configuration constants
  static const String _baseUrl = "https://aripsalin.elkedeseen.com";

  // Base URL configuration
  static String get baseUrl {
    // Check for environment variable first
    const String envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envBaseUrl.isNotEmpty) {
      return envBaseUrl;
    }

    // Always use the domain for both development and production
    // This avoids Netlify redirect issues and ensures direct API communication
    return _baseUrl;
  }

  // Helper method to get the appropriate URL based on current context
  static String getApiUrl(String endpoint) {
    // Always return full URL with domain to avoid Netlify redirect issues
    final String fullEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$baseUrl$fullEndpoint';
  }

  // Debug information
  static Map<String, dynamic> get debugInfo => {
    'isWeb': isWeb,
    'currentScheme': isWeb ? Uri.base.scheme : 'native',
    'baseUrl': baseUrl,
    'currentHost': isWeb ? Uri.base.host : 'native',
    'apiStrategy': 'Direct domain calls (no proxy)',
  };

}