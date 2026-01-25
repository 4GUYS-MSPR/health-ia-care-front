import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

import '../log_formatter.dart';
import 'log_handler.dart';

/// A log handler that writes formatted log records to files with rotation.
///
/// Features:
/// - Writes logs to a file in the app's documents directory
/// - Rotates log files when they exceed the maximum size
/// - Keeps a configurable number of rotated log files
/// - Buffers writes for performance
/// - Not available on web platform
class FileLogHandler implements LogHandler {
  final LogFormatter _formatter;
  final String _relativePath;
  final int _maxSizeKb;
  final int _maxFileCount;

  File? _currentFile;
  IOSink? _sink;
  int _currentSize = 0;
  bool _isInitialized = false;
  final List<String> _buffer = [];
  Timer? _flushTimer;

  /// Creates a file log handler.
  ///
  /// - [formatter]: The log formatter to use
  /// - [relativePath]: Path relative to app documents directory (e.g., "logs/app.log")
  /// - [maxSizeKb]: Maximum size of a single log file in kilobytes
  /// - [maxFileCount]: Maximum number of rotated log files to keep
  FileLogHandler({
    required LogFormatter formatter,
    required String relativePath,
    required int maxSizeKb,
    required int maxFileCount,
  }) : _formatter = formatter,
       _relativePath = relativePath,
       _maxSizeKb = maxSizeKb,
       _maxFileCount = maxFileCount;

  /// Checks if file logging is supported on the current platform.
  static bool get isSupported => !kIsWeb;

  /// Initializes the file handler.
  ///
  /// Must be called before handling log records.
  Future<void> init() async {
    if (!isSupported || _isInitialized) return;

    try {
      final directory = await getApplicationCacheDirectory();
      final filePath =
          '${directory.path}${Platform.pathSeparator}$_relativePath';

      _currentFile = File(filePath);

      // Ensure parent directories exist
      await _currentFile!.parent.create(recursive: true);

      // Create file if it doesn't exist
      if (!await _currentFile!.exists()) {
        await _currentFile!.create();
      }

      // Get current file size
      _currentSize = await _currentFile!.length();

      // Open file for appending
      _sink = _currentFile!.openWrite(mode: FileMode.append);

      // Start periodic flush timer (every 5 seconds)
      _flushTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _flush(),
      );

      _isInitialized = true;
    } catch (e) {
      // If file logging fails to initialize, we'll just skip file logging
      debugPrint('Failed to initialize file log handler: $e');
    }
  }

  @override
  void handle(LogRecord record) {
    if (!_isInitialized || _sink == null) return;

    final formatted = _formatter.format(record);
    _buffer.add(formatted);

    // Flush immediately if buffer gets large
    if (_buffer.length >= 100) {
      _flush();
    }
  }

  /// Flushes the buffer to the file.
  Future<void> _flush() async {
    if (_buffer.isEmpty || _sink == null) return;

    try {
      for (final line in _buffer) {
        _sink!.writeln(line);
        _currentSize += line.length + 1; // +1 for newline
      }
      _buffer.clear();

      await _sink!.flush();

      // Check if rotation is needed
      if (_currentSize >= _maxSizeKb * 1024) {
        await _rotate();
      }
    } catch (e) {
      debugPrint('Failed to flush log buffer: $e');
    }
  }

  /// Rotates log files.
  ///
  /// Renames current log file with a timestamp suffix and starts a new file.
  /// Removes old log files if the count exceeds [_maxFileCount].
  Future<void> _rotate() async {
    if (_currentFile == null) return;

    try {
      // Close current sink
      await _sink?.close();
      _sink = null;

      // Rename current file with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final rotatedPath = '${_currentFile!.path}.$timestamp';
      await _currentFile!.rename(rotatedPath);

      // Create new log file
      _currentFile = File(_currentFile!.path.replaceAll('.$timestamp', ''));
      await _currentFile!.create();
      _sink = _currentFile!.openWrite(mode: FileMode.append);
      _currentSize = 0;

      // Clean up old log files
      await _cleanupOldFiles();
    } catch (e) {
      debugPrint('Failed to rotate log file: $e');
    }
  }

  /// Removes old log files exceeding [_maxFileCount].
  Future<void> _cleanupOldFiles() async {
    if (_currentFile == null) return;

    try {
      final directory = _currentFile!.parent;
      final baseName = _currentFile!.uri.pathSegments.last;

      // Find all rotated log files
      final files = await directory.list().where((entity) {
        if (entity is! File) return false;
        final name = entity.uri.pathSegments.last;
        return name.startsWith(baseName) && name != baseName;
      }).toList();

      // Sort by modification time (oldest first)
      final fileList = files.cast<File>();
      final fileTimes = <File, DateTime>{};
      for (final file in fileList) {
        fileTimes[file] = await file.lastModified();
      }
      fileList.sort((a, b) => fileTimes[a]!.compareTo(fileTimes[b]!));

      // Remove oldest files if we have too many
      // -1 because we don't count the current file
      while (fileList.length >= _maxFileCount) {
        final oldest = fileList.removeAt(0);
        await oldest.delete();
      }
    } catch (e) {
      debugPrint('Failed to cleanup old log files: $e');
    }
  }

  @override
  Future<void> dispose() async {
    _flushTimer?.cancel();
    _flushTimer = null;

    // Final flush
    await _flush();

    await _sink?.close();
    _sink = null;
    _isInitialized = false;
  }
}
