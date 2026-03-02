class AppConfig {
  static const String env =
      String.fromEnvironment('GT_ENV', defaultValue: 'staging');

  // Example:
  // --dart-define=GT_API_BASE_URL=https://api.greentill.co
  static const String apiBaseUrl = String.fromEnvironment(
    'GT_API_BASE_URL',
    defaultValue: 'https://greentill-api.apps.openxcell.dev',
  );

  static const String apiBaseHost = String.fromEnvironment(
    'GT_API_BASE_HOST',
    defaultValue: 'greentill-api.apps.openxcell.dev',
  );
}
