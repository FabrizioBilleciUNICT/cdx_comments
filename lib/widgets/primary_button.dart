import 'package:flutter/material.dart';

/// A primary action button widget.
///
/// This is a simple replacement for the cdx_bootstrap PrimaryButton.
/// It supports loading state, enabled/disabled state, and custom styling.
class PrimaryButton extends StatelessWidget {
  /// The callback to execute when the button is pressed.
  final VoidCallback? onPressed;

  /// The text to display on the button.
  final String text;

  /// Whether the button is enabled.
  final bool enabled;

  /// Whether the button is in a loading state.
  final bool loading;

  /// Optional custom style for the button.
  final ButtonStyle? style;

  /// Optional text/foreground color. Use e.g. [Colors.white] on colored background.
  final Color? foregroundColor;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.enabled = true,
    this.loading = false,
    this.style,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled && !loading ? onPressed : null,
        style: style ?? ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: foregroundColor != null
                    ? TextStyle(color: foregroundColor)
                    : null,
              ),
      ),
    );
  }
}

