import 'package:equatable/equatable.dart';

/// Diagnostic information collected from the device and app.
class DiagnosticInfo extends Equatable {
  const DiagnosticInfo({
    required this.appName,
    required this.appVersion,
    required this.buildNumber,
    required this.packageName,
    required this.platform,
    required this.operatingSystem,
    required this.osVersion,
    required this.deviceModel,
    required this.deviceBrand,
    required this.screenSize,
    required this.screenPixelRatio,
    required this.locale,
    required this.timestamp,
    required this.isDebugMode,
    required this.isProfileMode,
    required this.isReleaseMode,
  });

  final String appName;
  final String appVersion;
  final String buildNumber;
  final String packageName;
  final String platform;
  final String operatingSystem;
  final String osVersion;
  final String deviceModel;
  final String deviceBrand;
  final String screenSize;
  final double screenPixelRatio;
  final String locale;
  final DateTime timestamp;
  final bool isDebugMode;
  final bool isProfileMode;
  final bool isReleaseMode;

  /// Formats the diagnostic info as a readable string.
  String format() {
    final buffer = StringBuffer();

    buffer.writeln('APP INFO:');
    buffer.writeln('Name: $appName');
    buffer.writeln('Version: $appVersion ($buildNumber)');
    buffer.writeln('Package: $packageName');
    buffer.writeln('Build Mode: $_buildMode');
    buffer.writeln();

    buffer.writeln('DEVICE INFO:');
    buffer.writeln('Platform: $platform');
    buffer.writeln('OS: $osVersion');
    buffer.writeln('Device: $deviceBrand $deviceModel');
    buffer.writeln();

    buffer.writeln('DISPLAY INFO:');
    buffer.writeln('Screen Size: $screenSize');
    buffer.writeln('Pixel Ratio: ${screenPixelRatio.toStringAsFixed(2)}x');
    buffer.writeln();

    buffer.writeln('ENVIRONMENT:');
    buffer.writeln('Locale: $locale');
    buffer.writeln('Timestamp: ${timestamp.toIso8601String()}');

    return buffer.toString();
  }

  String get _buildMode {
    if (isReleaseMode) return 'Release';
    if (isProfileMode) return 'Profile';
    if (isDebugMode) return 'Debug';
    return 'Unknown';
  }

  @override
  List<Object?> get props => [
    appName,
    appVersion,
    buildNumber,
    packageName,
    platform,
    operatingSystem,
    osVersion,
    deviceModel,
    deviceBrand,
    screenSize,
    screenPixelRatio,
    locale,
    timestamp,
    isDebugMode,
    isProfileMode,
    isReleaseMode,
  ];
}
