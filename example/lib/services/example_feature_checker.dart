import 'package:cdx_comments/cdx_comments.dart';

/// Example implementation of FeatureChecker.
///
/// This implementation enables all features and insights by default.
/// In a real app, you would implement this based on your configuration
/// or user permissions.
class ExampleFeatureChecker implements FeatureChecker {
  /// Creates a new [ExampleFeatureChecker].
  ///
  /// By default, all features and insights are enabled.
  ExampleFeatureChecker();

  @override
  bool commentHasFeature(ModuleFeature feature) {
    // Enable all features by default
    return true;
  }

  @override
  bool commentHasInsight(ModuleInsight insight) {
    // Show all insights by default
    return true;
  }
}

