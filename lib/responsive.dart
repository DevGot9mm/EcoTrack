import 'package:flutter/widgets.dart';

enum WindowSize { compact, medium, expanded }

extension WindowSizeX on BuildContext {
  WindowSize get windowSize {
    final double width = MediaQuery.sizeOf(this).width;
    if (width < 600) return WindowSize.compact;
    if (width < 840) return WindowSize.medium;
    return WindowSize.expanded;
  }
}
