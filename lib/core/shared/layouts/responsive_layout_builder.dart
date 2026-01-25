import 'package:flutter/material.dart';

import '../../constants/layout_breakpoints.dart';

class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget compact;
  final Widget? medium;
  final Widget? expanded;
  final Widget? large;
  final Widget? extraLarge;
  final LayoutBreakpoints breakpoints;

  ResponsiveLayoutBuilder({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
    LayoutBreakpoints? breakpoints,
  }) : breakpoints = breakpoints ?? StandardLayoutBreakpoints();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // List of breakpoint-widget pairs, ordered from largest to smallest.
        final breakpointsList = [
          [breakpoints.extraLarge, extraLarge],
          [breakpoints.large, large],
          [breakpoints.expanded, expanded],
          [breakpoints.medium, medium],
        ];

        for (final pair in breakpointsList) {
          final bp = pair[0] as double;
          final widget = pair[1] as Widget?;
          if (width >= bp && widget != null) {
            return widget;
          }
        }

        // Default to compact if no other breakpoints are matched.
        return compact;
      },
    );
  }
}
