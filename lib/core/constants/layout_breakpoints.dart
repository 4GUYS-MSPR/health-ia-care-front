/// An abstract class that defines layout breakpoint values for responsive design.
abstract class LayoutBreakpoints {
  double get medium;
  double get expanded;
  double get large;
  double get extraLarge;
}

/// Provides standard layout breakpoints based on Material Design 3 guidelines,
/// defining threshold values for medium, expanded, large, and extra large layouts.
class StandardLayoutBreakpoints implements LayoutBreakpoints {
  @override
  double get medium => 600;

  @override
  double get expanded => 840;

  @override
  double get large => 1200;

  @override
  double get extraLarge => 1600;
}
