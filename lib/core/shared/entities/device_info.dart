import 'package:equatable/equatable.dart';

/// Device information data class.
class DeviceInfo extends Equatable {
  const DeviceInfo({
    required this.os,
    required this.osVersion,
    required this.model,
    required this.brand,
  });

  /// The operating system name (e.g., "Android", "iOS", "Windows").
  final String os;

  /// The full OS version string.
  final String osVersion;

  /// The device model.
  final String model;

  /// The device brand/manufacturer.
  final String brand;

  /// Gets a formatted device string (e.g., "Samsung Galaxy S21").
  String get formattedDevice => '$brand $model';

  @override
  List<Object?> get props => [
    os,
    osVersion,
    model,
    brand,
  ];
}
