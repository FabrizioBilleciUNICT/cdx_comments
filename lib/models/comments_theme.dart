import 'package:flutter/material.dart';

/// Theme configuration for the comments package.
///
/// This interface allows customization of colors and styling used throughout
/// the comments widgets. If not provided, the package will use default values
/// based on the current [Theme] from the [BuildContext].
abstract class CommentsTheme {
  /// Primary color used for avatars and accent elements.
  Color get primary;

  /// Main text color (typically used for backgrounds in dark mode).
  Color get mainText;

  /// Main background color (typically used for text in dark mode).
  Color get mainBackground;

  /// Error color for delete actions and error messages.
  Color get error;

  /// Minor text color for secondary text.
  Color get minorText;

  /// Color for like/heart icon when liked.
  Color get likeColor;

  /// Border radius for card elements.
  BorderRadius get cardRadius;
}

/// Default implementation of [CommentsTheme] that uses [Theme.of].
///
/// This implementation extracts colors from the current Flutter theme,
/// making it compatible with any Material Design theme.
class DefaultCommentsTheme implements CommentsTheme {
  final BuildContext context;

  const DefaultCommentsTheme(this.context);

  @override
  Color get primary => Theme.of(context).colorScheme.primary;

  @override
  Color get mainText => Theme.of(context).colorScheme.surface;

  @override
  Color get mainBackground => Theme.of(context).colorScheme.onSurface;

  @override
  Color get error => Theme.of(context).colorScheme.error;

  @override
  Color get minorText => Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

  @override
  Color get likeColor => primary;

  @override
  BorderRadius get cardRadius => const BorderRadius.vertical(
    top: Radius.circular(16),
  );
}

