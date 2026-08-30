import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ProjectName/core/feature_flags/feature_flag_notifier.dart';
import 'package:ProjectName/domain/entities/feature_flags/auth_feature_flags.dart';
import 'package:ProjectName/domain/entities/feature_flags/feature_flag_state.dart';
import 'package:ProjectName/domain/entities/feature_flags/profile_feature_flags.dart';
import 'package:ProjectName/domain/repositories/feature_flag_repository.dart';

class _MockFeatureFlagRepository extends Mock implements FeatureFlagRepository {}

void main() {
  late _MockFeatureFlagRepository repository;
  late FeatureFlagNotifier notifier;

  setUp(() {
    repository = _MockFeatureFlagRepository();
    notifier = FeatureFlagNotifier(repository);
  });

  test('state defaults to disabled before initialize', () {
    expect(notifier.state, FeatureFlagState.disabled);
  });

  test('initialize fetches from repository and notifies listeners', () async {
    const fetched = FeatureFlagState(
      auth: AuthFeatureFlags(forgotPasswordEnabled: true),
      profile: ProfileFeatureFlags(profileV2Enabled: false),
    );
    when(() => repository.getFeatureFlags()).thenAnswer((_) async => fetched);

    var notified = false;
    notifier.addListener(() => notified = true);

    await notifier.initialize();

    expect(notifier.state, fetched);
    expect(notified, isTrue);
  });
}
