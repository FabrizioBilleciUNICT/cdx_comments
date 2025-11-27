# cdx_comments

A Flutter package for managing comments with support for replies, likes, reporting, and user blocking. Built with a clean, extensible architecture that follows Flutter best practices.

## Features

- 💬 **Comments & Replies**: Full support for threaded comments
- 👍 **Likes**: Like/unlike functionality with count display
- 🛡️ **Validation**: Built-in validation for bad words, dangerous content, and length limits
- 🚨 **Reporting**: Report comments and users
- 🚫 **User Blocking**: Block users functionality
- 🌍 **Internationalization**: Support for multiple languages (English, Italian) with extensible localization
- 🎨 **Customizable**: Feature flags and insights system for flexible configuration
- 📦 **Clean Architecture**: Service-based architecture with dependency injection support

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  cdx_comments:
    git:
      url: https://github.com/yourusername/cdx_comments.git
      # or use path for local development
      # path: ../cdx_comments
  provider: ^6.1.5+1
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
```

## Getting Started

### 1. Setup Localization

Add the localization delegates to your `MaterialApp`:

```dart
import 'package:cdx_comments/cdx_comments.dart';

MaterialApp(
  localizationsDelegates: [
    ...CdxCommentsLocalizations.localizationsDelegates,
    // Add your other delegates here
  ],
  supportedLocales: CdxCommentsLocalizations.supportedLocales,
  // ... rest of your app
)
```

### 2. Implement Required Services

You need to implement the `CommentService` interface:

```dart
class MyCommentService implements CommentService {
  @override
  Future<List<Comment>> fetchComments(String entityId, CommentConfig config, int page) async {
    // Your implementation
  }
  
  @override
  Future<Comment?> postComment(Comment comment, CommentConfig config) async {
    // Your implementation
  }
  
  // ... implement other methods
}
```

### 3. Implement Feature Checker

Implement the `FeatureChecker` interface:

```dart
class MyFeatureChecker implements FeatureChecker {
  @override
  bool commentHasFeature(ModuleFeature feature) {
    // Return true if feature is enabled
    return true; // or your logic
  }
  
  @override
  bool commentHasInsight(ModuleInsight insight) {
    // Return true if insight should be shown
    return true; // or your logic
  }
}
```

### 4. Create Comment Provider

```dart
final service = MyCommentService();
final config = CommentConfig(badWords: 'your bad words list');
final user = UserInfo(uuid: 'user-id', name: 'User Name');
final controller = CommentController(
  service: service,
  config: config,
  user: user,
);
final validator = CommentValidator(badWordsData: config.badWords);

final provider = CommentProvider(
  controller: controller,
  postId: 'entity-id',
  validator: validator,
);
```

### 5. Use the Widget

```dart
ChangeNotifierProvider(
  create: (_) => provider,
  child: CommentBottomSheet(
    userBlockedUntil: null, // or DateTime if user is blocked
    featureChecker: MyFeatureChecker(),
    service: service,
    user: user,
  ),
)
```

## Complete Example

```dart
import 'package:cdx_comments/cdx_comments.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        ...CdxCommentsLocalizations.localizationsDelegates,
      ],
      supportedLocales: CdxCommentsLocalizations.supportedLocales,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Setup your services
    final service = MyCommentService();
    final config = CommentConfig(badWords: '');
    final user = UserInfo(uuid: 'user-1', name: 'John Doe');
    final controller = CommentController(
      service: service,
      config: config,
      user: user,
    );
    final validator = CommentValidator(badWordsData: config.badWords);
    
    return Scaffold(
      appBar: AppBar(title: Text('Comments Example')),
      body: ChangeNotifierProvider(
        create: (_) => CommentProvider(
          controller: controller,
          postId: 'post-1',
          validator: validator,
        ),
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => CommentBottomSheet(
                  userBlockedUntil: null,
                  featureChecker: MyFeatureChecker(),
                  service: service,
                  user: user,
                ),
              );
            },
            child: Text('Show Comments'),
          ),
        ),
      ),
    );
  }
}
```

## Architecture

The package follows a clean architecture pattern:

- **Models**: Data classes (`Comment`, `UserInfo`, `CommentConfig`)
- **Services**: Abstract interfaces (`CommentService`, `FeatureChecker`)
- **Controllers**: Business logic (`CommentController`)
- **Providers**: State management (`CommentProvider`, `CommentReportProvider`)
- **Validators**: Input validation (`CommentValidator`)
- **Widgets**: UI components (`CommentBottomSheet`, `CommentTile`)

## Adding Custom Translations

To add support for additional languages:

1. Create a new ARB file in `lib/l10n/` (e.g., `app_fr.arb`)
2. Copy the structure from `app_en.arb`
3. Translate all the strings
4. Regenerate localizations: `flutter gen-l10n`

The delegate is extensible and can be combined with other localization delegates.

## API Reference

### Models

- `Comment`: Represents a comment with replies
- `UserInfo`: Current user information
- `CommentConfig`: Configuration for comments module
- `ModuleFeature`: Available features (comment, like)
- `ModuleInsight`: Available insights (likeCount)

### Services

- `CommentService`: Interface for comment operations
- `FeatureChecker`: Interface for feature/insight checking

### Widgets

- `CommentBottomSheet`: Main comments UI widget
- `CommentTile`: Individual comment widget
- `ReportCommentBottomSheet`: Report dialog widget

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
