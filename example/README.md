# CDX Comments Example

This is an example application demonstrating how to use the `cdx_comments` package.

## Features Demonstrated

- ✅ Setting up localization with `CdxCommentsLocalizations`
- ✅ Implementing `CommentService` (in-memory example)
- ✅ Implementing `FeatureChecker`
- ✅ Using `CommentProvider` for state management
- ✅ Displaying comments with custom simplified widgets
- ✅ Posting comments and replies
- ✅ Liking/unliking comments
- ✅ Deleting comments
- ✅ Expanding replies
- ✅ Comment validation
- ✅ Error handling

## Note

This example uses simplified widgets (`SimpleCommentList`) that don't require
`cdx_core` and `cdx_bootstrap` dependencies. The full-featured widgets
(`CommentBottomSheet`, `CommentTile`) from the package require those dependencies.

For a complete example using the full widgets, ensure `cdx_core` and `cdx_bootstrap`
are available in your project.

## Running the Example

1. Make sure you have Flutter installed
2. Navigate to this directory:
   ```bash
   cd example
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Implementation Details

### ExampleCommentService

This is a simple in-memory implementation of `CommentService` that demonstrates:
- Fetching comments
- Posting comments and replies
- Toggling likes
- Deleting comments
- Reporting functionality

In a real application, you would replace this with an implementation that calls your backend API.

### ExampleFeatureChecker

This implementation enables all features and insights by default. In a real app, you would implement this based on your configuration or user permissions.

## Customization

You can customize the example by:
- Modifying the `CommentConfig` to change bad words list
- Changing the `UserInfo` to use different user data
- Implementing a real `CommentService` that calls your API
- Customizing the `FeatureChecker` based on your needs

