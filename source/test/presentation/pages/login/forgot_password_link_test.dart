import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:ProjectName/core/feature_flags/feature_flag_notifier.dart';
import 'package:ProjectName/domain/entities/feature_flags/auth_feature_flags.dart';
import 'package:ProjectName/domain/entities/feature_flags/feature_flag_state.dart';
import 'package:ProjectName/domain/entities/feature_flags/profile_feature_flags.dart';
import 'package:ProjectName/domain/repositories/feature_flag_repository.dart';
import 'package:ProjectName/presentation/pages/login/components/forgot_password_link.dart';

class _MockFeatureFlagRepository extends Mock implements FeatureFlagRepository {}

FeatureFlagState _stateWith({required bool forgotPasswordEnabled}) {
  return FeatureFlagState(
    auth: AuthFeatureFlags(forgotPasswordEnabled: forgotPasswordEnabled),
    profile: const ProfileFeatureFlags(profileV2Enabled: false),
  );
}

Widget _wrap(FeatureFlagNotifier notifier) {
  return MaterialApp(
    home: ChangeNotifierProvider.value(
      value: notifier,
      child: const Scaffold(body: ForgotPasswordLink()),
    ),
  );
}

Future<FeatureFlagNotifier> _notifierWith({required bool forgotPasswordEnabled}) async {
  final repository = _MockFeatureFlagRepository();
  when(() => repository.getFeatureFlags())
      .thenAnswer((_) async => _stateWith(forgotPasswordEnabled: forgotPasswordEnabled));
  final notifier = FeatureFlagNotifier(repository);
  await notifier.initialize();
  return notifier;
}

void main() {
  testWidgets('shows the button when the flag is enabled', (tester) async {
    final notifier = await _notifierWith(forgotPasswordEnabled: true);

    await tester.pumpWidget(_wrap(notifier));

    expect(find.text('Forgot Password'), findsOneWidget);
  });

  testWidgets('hides the button when the flag is disabled', (tester) async {
    final notifier = await _notifierWith(forgotPasswordEnabled: false);

    await tester.pumpWidget(_wrap(notifier));

    expect(find.text('Forgot Password'), findsNothing);
  });
}
