import 'package:cdx_comments/cdx_comments.dart';

/// In-memory implementation of FeatureChecker for testing
class InMemoryFeatureChecker implements FeatureChecker {
  final Set<ModuleFeature> _enabledFeatures;
  final Set<ModuleInsight> _enabledInsights;

  InMemoryFeatureChecker({
    Set<ModuleFeature>? enabledFeatures,
    Set<ModuleInsight>? enabledInsights,
  })  : _enabledFeatures = enabledFeatures ?? ModuleFeature.values.toSet(),
        _enabledInsights = enabledInsights ?? ModuleInsight.values.toSet();

  @override
  bool commentHasFeature(ModuleFeature feature) {
    return _enabledFeatures.contains(feature);
  }

  @override
  bool commentHasInsight(ModuleInsight insight) {
    return _enabledInsights.contains(insight);
  }
}

