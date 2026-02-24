import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of CdxCommentsLocalizations
/// returned by `CdxCommentsLocalizations.of(context)`.
///
/// Applications need to include `CdxCommentsLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: CdxCommentsLocalizations.localizationsDelegates,
///   supportedLocales: CdxCommentsLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the CdxCommentsLocalizations.supportedLocales
/// property.
abstract class CdxCommentsLocalizations {
  CdxCommentsLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static CdxCommentsLocalizations? of(BuildContext context) {
    return Localizations.of<CdxCommentsLocalizations>(
      context,
      CdxCommentsLocalizations,
    );
  }

  static const LocalizationsDelegate<CdxCommentsLocalizations> delegate =
      _CdxCommentsLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// Title for comments section
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// Placeholder text for comment input field
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get add_a_comment;

  /// Button text to reply to a comment
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get answer;

  /// Label showing who you are replying to
  ///
  /// In en, this message translates to:
  /// **'Replying to'**
  String get answer_to;

  /// Delete action label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Title for delete comment dialog
  ///
  /// In en, this message translates to:
  /// **'Delete comment'**
  String get delete_comment;

  /// Confirmation question for deleting a comment
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment?'**
  String get q_delete_comment;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Report action label
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// Question for reporting a comment
  ///
  /// In en, this message translates to:
  /// **'Why are you reporting this comment?'**
  String get q_report_comment;

  /// Question for reporting a user
  ///
  /// In en, this message translates to:
  /// **'What do you want to do?'**
  String get q_report_user;

  /// Checkbox label for reporting a user
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get report_user;

  /// Checkbox label for blocking a user
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get block_user;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get end;

  /// Success message after submitting a report
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully'**
  String get report_done;

  /// Label showing when user is blocked until
  ///
  /// In en, this message translates to:
  /// **'Blocked until'**
  String get blocked_until;

  /// Button text to view replies
  ///
  /// In en, this message translates to:
  /// **'View {count} replies'**
  String view_replies(int count);

  /// Button to load next page of replies
  ///
  /// In en, this message translates to:
  /// **'Load more replies'**
  String get load_more_replies;

  /// Error message when comment is empty
  ///
  /// In en, this message translates to:
  /// **'Comment cannot be empty'**
  String get comment_empty;

  /// Error message when comment has too many lines
  ///
  /// In en, this message translates to:
  /// **'Comment cannot exceed {maxLines} lines'**
  String comment_too_many_lines(int maxLines);

  /// Error message when comment is too long
  ///
  /// In en, this message translates to:
  /// **'Comment cannot exceed {maxLength} characters'**
  String comment_too_long(int maxLength);

  /// Error message when comment contains dangerous content
  ///
  /// In en, this message translates to:
  /// **'Comment contains dangerous content'**
  String get comment_dangerous;

  /// Error message when comment contains bad words
  ///
  /// In en, this message translates to:
  /// **'Comment contains inappropriate words'**
  String get comment_bad_words;
}

class _CdxCommentsLocalizationsDelegate
    extends LocalizationsDelegate<CdxCommentsLocalizations> {
  const _CdxCommentsLocalizationsDelegate();

  @override
  Future<CdxCommentsLocalizations> load(Locale locale) {
    return SynchronousFuture<CdxCommentsLocalizations>(
      lookupCdxCommentsLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_CdxCommentsLocalizationsDelegate old) => false;
}

CdxCommentsLocalizations lookupCdxCommentsLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return CdxCommentsLocalizationsEn();
    case 'it':
      return CdxCommentsLocalizationsIt();
  }

  throw FlutterError(
    'CdxCommentsLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
