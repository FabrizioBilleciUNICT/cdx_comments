/// A Flutter package for managing comments with support for replies, likes, and reporting.
library cdx_comments;

// Models
export 'models/comment.dart';
export 'models/comment_config.dart';
export 'models/user_info.dart';
export 'models/module_features.dart';
export 'models/comments_theme.dart';
export 'models/comments_app_actions.dart';
export 'models/comments_text_style.dart';

// Services
export 'services/comment_service.dart';

// Controllers
export 'controller.dart';

// Providers
export 'provider.dart';
export 'report/provider.dart';

// Validators
export 'validator.dart';

// Widgets
export 'widgets/comment_tile.dart';
export 'widgets/sheet.dart';
export 'widgets/primary_button.dart';
export 'widgets/line_divider.dart';
export 'report/sheet.dart';

// Localization
export 'l10n/app_localizations.dart';

// Report models
export 'report/report.dart';

// Utils
export 'utils/date_formatter.dart';

