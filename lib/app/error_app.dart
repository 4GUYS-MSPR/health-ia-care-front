import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../l10n/generated/app_localizations.dart';
import '../core/extensions/l10n_extension.dart';
import '../core/extensions/theme_extension.dart';
import '../core/shared/entities/diagnostic_info.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/diagnostic_utils.dart';

/// A fallback app displayed when the main app fails to start.
///
/// This app is intentionally minimal and self-contained, avoiding
/// dependencies that may have caused the startup failure.
class ErrorApp extends StatelessWidget {
  const ErrorApp({
    super.key,
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _ErrorPage(error: error, stackTrace: stackTrace),
    );
  }
}

class _ErrorPage extends StatelessWidget {
  const _ErrorPage({
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Icon(
                  Symbols.error_rounded,
                  size: 100,
                  color: context.colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  context.l10n.errorAppTitle,
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.errorAppMessage,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showErrorDetails(context),
                  icon: const Icon(Symbols.bug_report),
                  label: Text(context.l10n.errorAppViewDetails),
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.fromMap({
                      WidgetState.pressed: context.colorScheme.onSurface
                          .withAlpha(25),
                      WidgetState.hovered: context.colorScheme.onSurface
                          .withAlpha(20),
                      WidgetState.focused: context.colorScheme.onSurface
                          .withAlpha(25),
                    }),
                    foregroundColor: WidgetStatePropertyAll(
                      context.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showErrorDetails(BuildContext context) async {
    final diagnosticInfo = await DiagnosticUtils.collect(context);
    final errorDetails = _formatErrorDetails(diagnosticInfo);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _ErrorDetailsSheet(
          errorDetails: errorDetails,
          scrollController: scrollController,
        ),
      ),
    );
  }

  String _formatErrorDetails(DiagnosticInfo diagnosticInfo) {
    final buffer = StringBuffer();

    // Error details
    buffer.writeln('ERROR:');
    buffer.writeln(error.toString());
    buffer.writeln();

    buffer.writeln('STACK TRACE:');
    buffer.writeln(stackTrace.toString());

    // Diagnostic info
    buffer.write(diagnosticInfo.format());
    buffer.writeln();
    return buffer.toString();
  }
}

class _ErrorDetailsSheet extends StatelessWidget {
  const _ErrorDetailsSheet({
    required this.errorDetails,
    required this.scrollController,
  });

  final String errorDetails;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.errorAppDetailsTitle,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _copyToClipboard(context),
            icon: const Icon(Symbols.content_copy_rounded),
            tooltip: context.l10n.errorAppCopyToClipboard,
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Symbols.close_rounded),
            tooltip: context.l10n.errorAppCloseTooltip,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        errorDetails,
        style: context.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: errorDetails));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.errorAppCopiedToClipboard),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
