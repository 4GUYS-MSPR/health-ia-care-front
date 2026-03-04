import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Utility class for retrieving application package information.
///
/// Must be initialized once during app startup before accessing properties.
///
/// Usage:
/// ```dart
/// // During app startup
/// await AppInfoUtils.initialize();
///
/// // Then access sync anywhere
/// final version = AppInfoUtils.version;
/// final fullVersion = AppInfoUtils.fullVersion; // "1.0.0 (42)"
/// ```
class AppInfoUtils {
  AppInfoUtils._();

  static PackageInfo? _packageInfo;
  static bool _isInitialized = false;

  /// Whether the utility has been initialized.
  static bool get isInitialized => _isInitialized;

  /// Initializes the utility by loading package info.
  ///
  /// Must be called once during app startup before accessing properties.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _packageInfo = await PackageInfo.fromPlatform();
    } catch (_) {
      _packageInfo = PackageInfo(
        appName: 'Unknown',
        packageName: 'Unknown',
        version: 'Unknown',
        buildNumber: 'Unknown',
        buildSignature: '',
      );
    }
    _isInitialized = true;
  }

  /// Resets the initialization state.
  ///
  /// Useful for testing.
  @visibleForTesting
  static void reset() {
    _packageInfo = null;
    _isInitialized = false;
  }

  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'AppInfoUtils has not been initialized. '
        'Call AppInfoUtils.initialize() during app startup.',
      );
    }
  }

  /// Gets the full package info.
  static PackageInfo get packageInfo {
    _ensureInitialized();
    return _packageInfo!;
  }

  /// Gets the application name.
  static String get appName {
    _ensureInitialized();
    return _packageInfo!.appName;
  }

  /// Gets the package name (e.g., "com.example.app").
  static String get packageName {
    _ensureInitialized();
    return _packageInfo!.packageName;
  }

  /// Gets the version string (e.g., "1.0.0").
  static String get version {
    _ensureInitialized();
    return _packageInfo!.version;
  }

  /// Gets the build number (e.g., "42").
  static String get buildNumber {
    _ensureInitialized();
    return _packageInfo!.buildNumber;
  }

  /// Gets the full version string with build number (e.g., "1.0.0 (42)").
  static String get fullVersion {
    _ensureInitialized();
    return '${_packageInfo!.version} (${_packageInfo!.buildNumber})';
  }

  /// Gets the build signature (Android only).
  static String get buildSignature {
    _ensureInitialized();
    return _packageInfo!.buildSignature;
  }

  /// Whether the app is running in debug mode.
  static bool get isDebugMode => kDebugMode;

  /// Whether the app is running in profile mode.
  static bool get isProfileMode => kProfileMode;

  /// Whether the app is running in release mode.
  static bool get isReleaseMode => kReleaseMode;

  /// Gets the current build mode as a string.
  static String get buildMode {
    if (kReleaseMode) return 'Release';
    if (kProfileMode) return 'Profile';
    if (kDebugMode) return 'Debug';
    return 'Unknown';
  }
}
