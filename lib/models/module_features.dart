/// Features that can be enabled/disabled for the comments module
enum ModuleFeature {
  comment,
  like,
}

/// Insights that can be shown/hidden for the comments module
enum ModuleInsight {
  likeCount,
}

/// Interface for checking module features and insights
abstract class FeatureChecker {
  bool commentHasFeature(ModuleFeature feature);
  bool commentHasInsight(ModuleInsight insight);
}

