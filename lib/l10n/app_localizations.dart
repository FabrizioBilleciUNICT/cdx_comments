/// Extensible delegate for CdxCommentsLocalizations.
/// 
/// This delegate can be combined with other localization delegates
/// to support multiple languages and translations.
/// 
/// Example usage:
/// ```dart
/// MaterialApp(
///   localizationsDelegates: [
///     ...CdxCommentsLocalizations.localizationsDelegates,
///     // Add your custom delegates here
///   ],
///   supportedLocales: CdxCommentsLocalizations.supportedLocales,
///   // ...
/// )
/// ```
library cdx_comments.l10n;

export 'app_localizations_generated.dart';
