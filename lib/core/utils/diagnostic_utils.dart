import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../shared/entities/device_info.dart';
import '../shared/entities/diagnostic_info.dart';
import 'app_info_utils.dart';
import 'device_info_utils.dart';

/// Utility class for collecting comprehensive diagnostic information.
///
/// Combines app info, device info, and display info into a single report.
/// Useful for error reporting and debugging.
///
/// If [AppInfoUtils] or [DeviceInfoUtils] are not initialized, this will
/// attempt to initialize them or use fallback values.
///
/// Usage:
/// ```dart
/// final diagnostics = await DiagnosticUtils.collect(context);
/// print(diagnostics.format());
/// ```
class DiagnosticUtils {
  DiagnosticUtils._();

  /// Collects comprehensive diagnostic information from the current environment.
  ///
  /// If utilities are not initialized, this will initialize them first.
  /// Safe to call even if startup failed before initialization completed.
  static Future<DiagnosticInfo> collect(BuildContext context) async {
    // Ensure utilities are initialized, initialize if needed
    await _ensureInitialized();

    final packageInfo = AppInfoUtils.isInitialized
        ? AppInfoUtils.packageInfo
        : _fallbackPackageInfo;
    final deviceInfo = DeviceInfoUtils.isInitialized
        ? DeviceInfoUtils.deviceInfo
        : _fallbackDeviceInfo;

    // ignore: use_build_context_synchronously
    final mediaQuery = MediaQuery.maybeOf(context);
    final screenSize = mediaQuery?.size ?? Size.zero;
    final pixelRatio = mediaQuery?.devicePixelRatio ?? 1.0;

    return DiagnosticInfo(
      appName: packageInfo.appName,
      appVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      packageName: packageInfo.packageName,
      platform: DeviceInfoUtils.platformName,
      operatingSystem: deviceInfo.os,
      osVersion: deviceInfo.osVersion,
      deviceModel: deviceInfo.model,
      deviceBrand: deviceInfo.brand,
      screenSize:
          '${screenSize.width.toStringAsFixed(0)} x '
          '${screenSize.height.toStringAsFixed(0)}',
      screenPixelRatio: pixelRatio,
      locale: PlatformDispatcher.instance.locale.toString(),
      timestamp: DateTime.now(),
      isDebugMode: kDebugMode,
      isProfileMode: kProfileMode,
      isReleaseMode: kReleaseMode,
    );
  }

  static Future<void> _ensureInitialized() async {
    if (!AppInfoUtils.isInitialized) {
      try {
        await AppInfoUtils.initialize();
      } catch (_) {
        // Fallback values will be used
      }
    }
    if (!DeviceInfoUtils.isInitialized) {
      try {
        await DeviceInfoUtils.initialize();
      } catch (_) {
        // Fallback values will be used
      }
    }
  }

  static final _fallbackPackageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: '',
  );

  static const _fallbackDeviceInfo = DeviceInfo(
    os: 'Unknown',
    osVersion: 'Unknown',
    model: 'Unknown',
    brand: 'Unknown',
  );
}
