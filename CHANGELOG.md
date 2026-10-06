## 0.1.1

* [UserInfo.initials]: blank [name] now falls back to letters from [uuid] instead of a fixed placeholder.

## 0.1.0

* **Breaking:** [CommentsTheme] adds [likeIconSize]; [CommentsTextStyle] adds [commentUsername], [commentBody], [replyAction], [likeCount], [sheetTitle] for row-level typography.
* Comment sheet title is full-width centered; [CommentTile] and report sheet receive the host [CommentsTextStyle].
* Relaxed SDK constraint to `>=3.8.0 <4.0.0`.

## 0.0.6

* Replies pagination, more styling customizations

## 0.0.5

* Fixed logo image path in README (changed from main to master branch)

## 0.0.4

* Added logo image to README header

## 0.0.3

* Updated license copyright year to 2025

## 0.0.2

* Added intl dependency for date formatting and localization support

## 0.0.1

* Initial release of cdx_comments package
* Support for comments with replies
* Like/unlike functionality
* Comment validation (bad words, dangerous content, length limits)
* Report comments and users
* Block users
* Multi-language support (English and Italian)
* Extensible architecture with service interfaces
* Provider-based state management
* Feature flags and insights system
