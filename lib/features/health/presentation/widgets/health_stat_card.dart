import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_extension.dart';

enum HealthStatTone { primary, warm, success, cool }

class HealthStatCard extends StatelessWidget {
  const HealthStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final String value;
  final HealthStatTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForTone(context, tone);

    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: colors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      label,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _ToneColors _colorsForTone(BuildContext context, HealthStatTone tone) {
    final cs = context.colorScheme;

    return switch (tone) {
      HealthStatTone.primary => _ToneColors(accent: cs.primary, background: cs.primaryContainer),
      HealthStatTone.warm => _ToneColors(accent: cs.tertiary, background: cs.tertiaryContainer),
      HealthStatTone.success => _ToneColors(accent: cs.secondary, background: cs.secondaryContainer),
      HealthStatTone.cool => _ToneColors(accent: cs.primary, background: cs.surfaceContainerHighest),
    };
  }
}

class _ToneColors {
  const _ToneColors({required this.accent, required this.background});

  final Color accent;
  final Color background;
}
