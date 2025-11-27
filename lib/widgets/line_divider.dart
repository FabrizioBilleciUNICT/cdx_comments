import 'package:flutter/material.dart';

/// A simple horizontal divider widget.
///
/// This is a replacement for the cdx_bootstrap LineDivider.
class LineDivider extends StatelessWidget {
  /// The color of the divider.
  final Color color;

  /// The height/thickness of the divider.
  final double height;

  const LineDivider({
    super.key,
    required this.color,
    this.height = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: color,
    );
  }
}

