# cdx_comments

[![pub package](https://img.shields.io/pub/v/cdx_comments.svg)](https://pub.dev/packages/cdx_comments)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D1.17.0-blue.svg)](https://flutter.dev)

A comprehensive Flutter package for managing comments with support for replies, likes, reporting, and user blocking. Built with a clean, extensible architecture that follows Flutter best practices and requires zero external dependencies (except `provider`).

## Features

- 💬 **Threaded Comments**: Full support for nested replies and comment threads
- 👍 **Like System**: Like/unlike functionality with count display
- 🛡️ **Content Validation**: Built-in validation for bad words, dangerous content, and length limits
- 🚨 **Reporting System**: Report comments and users with customizable reasons
- 🚫 **User Blocking**: Block users functionality with optional time-based restrictions
- 🌍 **Internationalization**: Support for multiple languages (English, Italian) with extensible localization
- 🎨 **Highly Customizable**: Optional theme, text styles, and app actions customization
- 🔧 **Feature Flags**: Flexible feature and insight system for dynamic configuration
- 📦 **Clean Architecture**: Service-based architecture with dependency injection support
- 🧪 **Well Tested**: Comprehensive unit tests included

## Installation

Add `cdx_comments` to your `pubspec.yaml`:

```yaml
dependencies:
  cdx_comments: ^0.0.1
  provider: ^6.1.5+1
  flutter_localizations:
    sdk: flutter
```

Then run:

```bash
flutter pub get
```

## Quick Start

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

### 2. Implement CommentService

Implement the `CommentService` interface to connect with your backend:

```dart
class MyCommentService implements CommentService {
  @override
  Future<List<Comment>> fetchComments(
    String entityId,
    CommentConfig config,
    int page,
  ) async {
    // Fetch comments from your API
    final response = await http.get('/api/comments/$entityId?page=$page');
    // Parse and return comments
    return parseComments(response.body);
  }
  
  @override
  Future<Comment?> postComment(Comment comment, CommentConfig config) async {
    // Post comment to your API
    final response = await http.post('/api/comments', body: comment.toJson());
    return Comment.fromJson(response.body);
  }
  
  @override
  Future<Comment?> postReply(Comment comment) async {
    // Post reply to your API
    final response = await http.post('/api/replies', body: comment.toJson());
    return Comment.fromJson(response.body);
  }
  
  @override
  Future<Comment?> toggleLikeComment(String commentId) async {
    // Toggle like on your API
    final response = await http.post('/api/comments/$commentId/like');
    return Comment.fromJson(response.body);
  }
  
  @override
  Future<void> deleteComment(String commentId) async {
    // Delete comment on your API
    await http.delete('/api/comments/$commentId');
  }
  
  @override
  Future<List<Comment>> fetchReplies(String commentId, int page) async {
    // Fetch replies from your API
    final response = await http.get('/api/comments/$commentId/replies?page=$page');
    return parseComments(response.body);
  }
  
  @override
  Future<void> sendReportComment(String commentId, String reasonId) async {
    await http.post('/api/comments/$commentId/report', body: {'reason': reasonId});
  }
  
  @override
  Future<void> sendReportUser(String userId) async {
    await http.post('/api/users/$userId/report');
  }
  
  @override
  Future<void> sendBlockUser(String userId) async {
    await http.post('/api/users/$userId/block');
  }
}
```

### 3. Implement FeatureChecker

Control which features and insights are enabled:

```dart
class MyFeatureChecker implements FeatureChecker {
  final bool commentsEnabled;
  final bool likesEnabled;
  
  MyFeatureChecker({
    this.commentsEnabled = true,
    this.likesEnabled = true,
  });
  
  @override
  bool commentHasFeature(ModuleFeature feature) {
    switch (feature) {
      case ModuleFeature.comment:
        return commentsEnabled;
      case ModuleFeature.like:
        return likesEnabled;
    }
  }
  
  @override
  bool commentHasInsight(ModuleInsight insight) {
    switch (insight) {
      case ModuleInsight.likeCount:
        return likesEnabled; // Show count only if likes are enabled
    }
  }
}
```

### 4. Setup and Use

```dart
import 'package:cdx_comments/cdx_comments.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentsPage extends StatelessWidget {
  final String postId;
  
  const CommentsPage({super.key, required this.postId});
  
  @override
  Widget build(BuildContext context) {
    // Setup services
    final service = MyCommentService();
    final config = CommentConfig(
      badWords: 'bad\nword\nlist', // Your bad words list
    );
    final user = UserInfo(
      uuid: 'current-user-id',
      name: 'Current User',
    );
    final controller = CommentController(
      service: service,
      config: config,
      user: user,
    );
    final validator = CommentValidator(badWordsData: config.badWords);
    final featureChecker = MyFeatureChecker();
    
    return ChangeNotifierProvider(
      create: (_) => CommentProvider(
        controller: controller,
        postId: postId,
        validator: validator,
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Comments')),
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => CommentBottomSheet(
                  userBlockedUntil: null, // Set if user is blocked
                  featureChecker: featureChecker,
                  service: service,
                  user: user,
                ),
              );
            },
            child: const Text('Show Comments'),
          ),
        ),
      ),
    );
  }
}
```

## Customization

### Theme Customization

Customize colors and styling through the `CommentsTheme` interface:

```dart
class MyCustomTheme implements CommentsTheme {
  @override
  Color get primary => Colors.blue;
  
  @override
  Color get mainText => Colors.white;
  
  @override
  Color get mainBackground => Colors.black;
  
  @override
  Color get error => Colors.red;
  
  @override
  Color get minorText => Colors.grey;
  
  @override
  BorderRadius get cardRadius => BorderRadius.circular(20);
}

// Use it in CommentBottomSheet
CommentBottomSheet(
  // ... other parameters
  theme: MyCustomTheme(),
)
```

If not provided, the package uses `DefaultCommentsTheme` which automatically extracts colors from `Theme.of(context)`.

### App Actions Customization

Customize snackbars and dialogs:

```dart
class MyCustomAppActions implements CommentsAppActions {
  @override
  void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
  
  @override
  void showInfoSnackbar(BuildContext context, String message) {
    // Your custom implementation
  }
  
  @override
  void showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    required void Function(bool) onConfirm,
  }) {
    // Your custom dialog implementation
  }
}

// Use it in CommentBottomSheet
CommentBottomSheet(
  // ... other parameters
  appActions: MyCustomAppActions(),
)
```

### Text Style Customization

Customize text styles:

```dart
class MyCustomTextStyle implements CommentsTextStyle {
  final BuildContext context;
  
  const MyCustomTextStyle(this.context);
  
  @override
  TextStyle bold18({Color? color, TextAlign? align}) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      fontFamily: 'CustomFont',
    );
  }
  
  // Implement other methods: normal14, normal15, normal12
}

// Use it in CommentBottomSheet
CommentBottomSheet(
  // ... other parameters
  textStyle: MyCustomTextStyle(context),
)
```

## Architecture

The package follows clean architecture principles:

- **Models**: Immutable data classes (`Comment`, `UserInfo`, `CommentConfig`, `CommentsTheme`, etc.)
- **Services**: Abstract interfaces (`CommentService`, `FeatureChecker`) for dependency inversion
- **Controllers**: Business logic layer (`CommentController`)
- **Providers**: State management (`CommentProvider`, `CommentReportProvider`) using Provider pattern
- **Validators**: Input validation (`CommentValidator`)
- **Widgets**: Reusable UI components (`CommentBottomSheet`, `CommentTile`, `ReportCommentBottomSheet`)

## API Reference

### Core Models

#### `Comment`
Represents a comment with all its properties:
- `id`: Unique identifier
- `content`: Comment text
- `userId`: Author user ID
- `username`: Author username
- `date`: Creation date
- `parentId`: Parent comment ID (null for root comments)
- `entityId`: ID of the entity being commented on
- `replies`: List of reply comments
- `replyCount`: Total number of replies
- `isLiked`: Whether current user liked it
- `likeCount`: Number of likes
- `isMine`: Whether comment belongs to current user

#### `UserInfo`
Current user information:
- `uuid`: User unique identifier
- `name`: User display name
- `initials`: Generated initials from name

#### `CommentConfig`
Configuration for the comments module:
- `badWords`: String containing bad words list (one per line)

### Services

#### `CommentService`
Abstract interface for comment operations. You must implement:
- `fetchComments()`: Fetch comments for an entity
- `postComment()`: Post a new comment
- `postReply()`: Post a reply
- `toggleLikeComment()`: Toggle like status
- `deleteComment()`: Delete a comment
- `fetchReplies()`: Fetch replies for a comment
- `sendReportComment()`: Report a comment
- `sendReportUser()`: Report a user
- `sendBlockUser()`: Block a user

#### `FeatureChecker`
Interface for feature/insight checking:
- `commentHasFeature()`: Check if a feature is enabled
- `commentHasInsight()`: Check if an insight should be shown

### Widgets

#### `CommentBottomSheet`
Main comments UI widget. Parameters:
- `userBlockedUntil`: Optional DateTime if user is blocked
- `featureChecker`: Feature checker implementation
- `service`: Comment service implementation
- `user`: Current user information
- `theme`: Optional custom theme
- `appActions`: Optional custom app actions
- `textStyle`: Optional custom text styles

#### `CommentTile`
Individual comment widget. Displays comment content, actions, and replies.

#### `ReportCommentBottomSheet`
Bottom sheet for reporting comments and users.

## Adding Custom Translations

To add support for additional languages:

1. Create a new ARB file in `lib/l10n/` (e.g., `app_fr.arb`)
2. Copy the structure from `app_en.arb`
3. Translate all the strings
4. Regenerate localizations: `flutter gen-l10n`

The delegate is extensible and can be combined with other localization delegates in your app.

## Requirements

- Flutter >= 1.17.0
- Dart >= 3.10.1
- `provider` package (^6.1.5+1)

## Example

See the [example](example) directory for a complete working example.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Links

- [GitHub Repository](https://github.com/FabrizioBilleciUNICT/cdx_comments)
- [Pub.dev Package](https://pub.dev/packages/cdx_comments)
- [Issue Tracker](https://github.com/FabrizioBilleciUNICT/cdx_comments/issues)
