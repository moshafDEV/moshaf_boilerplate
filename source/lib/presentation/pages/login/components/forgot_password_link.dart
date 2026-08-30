import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ProjectName/core/constants/textstyle.dart';
import 'package:ProjectName/core/feature_flags/feature_flag_notifier.dart';
import 'package:ProjectName/core/routes/app_path.dart';

/// Split out from PasswordInputField so the auth.forgotPasswordEnabled gate
/// is testable without pulling in LoginBloc.
class ForgotPasswordLink extends StatelessWidget {
  const ForgotPasswordLink({super.key});

  @override
  Widget build(BuildContext context) {
    final enabled = context.watch<FeatureFlagNotifier>().state.auth.forgotPasswordEnabled;
    if (!enabled) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          context.push(Paths.forgotPassword);
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text('Forgot Password', style: genStyle14Medium),
      ),
    );
  }
}
