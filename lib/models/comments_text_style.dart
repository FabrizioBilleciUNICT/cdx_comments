import 'package:flutter/material.dart';

/// Text style configuration for comments widgets.
///
/// This interface allows customization of text styles used in the comments package.
/// If not provided, the package will use default styles based on the current [Theme].
abstract class CommentsTextStyle {
  /// Style for bold 18pt text (typically used for titles).
  TextStyle bold18({Color? color, TextAlign? align});

  /// Style for normal 14pt text.
  TextStyle normal14({Color? color, TextAlign? align});

  /// Style for normal 15pt text.
  TextStyle normal15({Color? color, TextAlign? align});

  /// Style for normal 12pt text.
  TextStyle normal12({Color? color, TextAlign? align});
}

/// Default implementation of [CommentsTextStyle] using [Theme.of].
class DefaultCommentsTextStyle implements CommentsTextStyle {
  final BuildContext context;

  const DefaultCommentsTextStyle(this.context);

  @override
  TextStyle bold18({Color? color, TextAlign? align}) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  @override
  TextStyle normal14({Color? color, TextAlign? align}) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  @override
  TextStyle normal15({Color? color, TextAlign? align}) {
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  @override
  TextStyle normal12({Color? color, TextAlign? align}) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }
}

