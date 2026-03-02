import 'package:greentill/config/app_config.dart';
import 'package:greentill/utils/shared_pref_helper.dart';

class RuntimeConfig {
  static const String _apiBaseUrlOverrideKey = "api_base_url_override";

  static String get apiBaseUrl {
    final override =
        SharedPrefHelper.instance.getString(_apiBaseUrlOverrideKey);
    if (override.trim().isNotEmpty) {
      return override.trim();
    }
    return AppConfig.apiBaseUrl;
  }

  static String get apiBaseHost {
    final uri = Uri.tryParse(apiBaseUrl);
    if (uri != null && uri.host.isNotEmpty) {
      return uri.host;
    }
    return AppConfig.apiBaseHost;
  }

  static bool get hasApiOverride {
    return SharedPrefHelper.instance
        .getString(_apiBaseUrlOverrideKey)
        .trim()
        .isNotEmpty;
  }

  static void setApiBaseUrlOverride(String baseUrl) {
    SharedPrefHelper.instance.putString(_apiBaseUrlOverrideKey, baseUrl.trim());
  }

  static void clearApiBaseUrlOverride() {
    SharedPrefHelper.instance.remove(_apiBaseUrlOverrideKey);
  }
}
