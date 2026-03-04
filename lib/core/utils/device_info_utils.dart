import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import '../shared/entities/device_info.dart';

/// Utility class for retrieving device and platform information.
///
/// Must be initialized once during app startup before accessing device info.
///
/// Usage:
/// ```dart
/// // During app startup
/// await DeviceInfoUtils.initialize();
///
/// // Then access sync anywhere
/// final platform = DeviceInfoUtils.platformName;
/// final device = DeviceInfoUtils.deviceInfo;
/// print('Device: ${device.brand} ${device.model}');
/// ```
class DeviceInfoUtils {
  DeviceInfoUtils._();

  static DeviceInfo? _deviceInfo;
  static bool _isInitialized = false;

  /// Whether the utility has been initialized.
  static bool get isInitialized => _isInitialized;

  /// Initializes the utility by loading device info.
  ///
  /// Must be called once during app startup before accessing device properties.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _deviceInfo = await _collectDeviceInfo();
    } catch (_) {
      _deviceInfo = const DeviceInfo(
        os: 'Unknown',
        osVersion: 'Unknown',
        model: 'Unknown',
        brand: 'Unknown',
      );
    }
    _isInitialized = true;
  }

  /// Resets the initialization state.
  ///
  /// Useful for testing.
  @visibleForTesting
  static void reset() {
    _deviceInfo = null;
    _isInitialized = false;
  }

  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'DeviceInfoUtils has not been initialized. '
        'Call DeviceInfoUtils.initialize() during app startup.',
      );
    }
  }

  /// Gets the device info.
  static DeviceInfo get deviceInfo {
    _ensureInitialized();
    return _deviceInfo!;
  }

  static Future<DeviceInfo> _collectDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      return DeviceInfo(
        os: 'Web',
        osVersion: webInfo.browserName.name,
        model: webInfo.platform ?? 'Unknown',
        brand: webInfo.vendor ?? 'Unknown',
      );
    }

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return DeviceInfo(
        os: 'Android',
        osVersion:
            'Android ${androidInfo.version.release} '
            '(SDK ${androidInfo.version.sdkInt})',
        model: androidInfo.model,
        brand: androidInfo.brand,
      );
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return DeviceInfo(
        os: 'iOS',
        osVersion: '${iosInfo.systemName} ${iosInfo.systemVersion}',
        model: iosInfo.utsname.machine,
        brand: 'Apple',
      );
    }

    if (Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      return DeviceInfo(
        os: 'Windows',
        osVersion:
            'Windows ${windowsInfo.majorVersion}.'
            '${windowsInfo.minorVersion} '
            '(Build ${windowsInfo.buildNumber})',
        model: windowsInfo.productName,
        brand: 'Microsoft',
      );
    }

    if (Platform.isMacOS) {
      final macInfo = await deviceInfo.macOsInfo;
      return DeviceInfo(
        os: 'macOS',
        osVersion:
            'macOS ${macInfo.majorVersion}.'
            '${macInfo.minorVersion}.${macInfo.patchVersion}',
        model: macInfo.model,
        brand: 'Apple',
      );
    }

    if (Platform.isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      return DeviceInfo(
        os: 'Linux',
        osVersion: linuxInfo.prettyName,
        model: linuxInfo.name,
        brand: linuxInfo.id,
      );
    }

    return const DeviceInfo(
      os: 'Unknown',
      osVersion: 'Unknown',
      model: 'Unknown',
      brand: 'Unknown',
    );
  }

  /// Gets the current platform name.
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isFuchsia) return 'Fuchsia';
    return 'Unknown';
  }

  /// Whether the app is running on a mobile platform (Android or iOS).
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Whether the app is running on a desktop platform.
  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// Whether the app is running on the web.
  static bool get isWeb => kIsWeb;
}
