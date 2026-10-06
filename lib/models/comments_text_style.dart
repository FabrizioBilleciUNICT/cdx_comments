import 'package:flutter/material.dart';

/// Text style configuration for comments widgets.
///
/// This interface allows customization of text styles used in the comments package.
/// If not provided, the package will use default styles based on the current [Theme].
///
/// Row-specific styles ([commentUsername], [commentBody], [replyAction], [likeCount],
/// [sheetTitle]) drive the main comment UI. The `normal*` / [bold18] helpers remain for
/// report flows, composer, and backwards compatibility.
abstract class CommentsTextStyle {
  /// Style for bold 18pt text (report sheets and legacy titles).
  TextStyle bold18({Color? color, TextAlign? align});

  /// Style for normal 14pt text.
  TextStyle normal14({Color? color, TextAlign? align});

  /// Style for normal 15pt text.
  TextStyle normal15({Color? color, TextAlign? align});

  /// Style for normal 12pt text.
  TextStyle normal12({Color? color, TextAlign? align});

  /// Comment list: author display name.
  TextStyle commentUsername({Color? color, TextAlign? align});

  /// Comment list: body text.
  TextStyle commentBody({Color? color, TextAlign? align});

  /// Comment list: "Reply" / answer action label.
  TextStyle replyAction({Color? color, TextAlign? align});

  /// Comment list: numeric like count below the heart icon.
  TextStyle likeCount({Color? color, TextAlign? align});

  /// Main comments sheet header (e.g. localized "Comments").
  TextStyle sheetTitle({Color? color, TextAlign? align});
}

/// Default implementation of [CommentsTextStyle] using [Theme.of].
class DefaultCommentsTextStyle implements CommentsTextStyle {
  final BuildContext context;

  const DefaultCommentsTextStyle(this.context);

  Color _onSurface(Color? color) =>
      color ?? Theme.of(context).colorScheme.onSurface;

  @override
  TextStyle bold18({Color? color, TextAlign? align}) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: _onSurface(color),
    );
  }

  @override
  TextStyle normal14({Color? color, TextAlign? align}) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: _onSurface(color),
    );
  }

  @override
  TextStyle normal15({Color? color, TextAlign? align}) {
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: _onSurface(color),
    );
  }

  @override
  TextStyle normal12({Color? color, TextAlign? align}) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: _onSurface(color),
    );
  }

  @override
  TextStyle commentUsername({Color? color, TextAlign? align}) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 1.0,
      color: _onSurface(color),
    );
  }

  @override
  TextStyle commentBody({Color? color, TextAlign? align}) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 20 / 14,
      color: _onSurface(color),
    );
  }

  @override
  TextStyle replyAction({Color? color, TextAlign? align}) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      height: 1.0,
      color: _onSurface(color),
    );
  }

  @override
  TextStyle likeCount({Color? color, TextAlign? align}) {
    return TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.normal,
      height: 1.0,
      color: _onSurface(color),
    );
  }

  @override
  TextStyle sheetTitle({Color? color, TextAlign? align}) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1.0,
      color: _onSurface(color),
    );
  }
}
