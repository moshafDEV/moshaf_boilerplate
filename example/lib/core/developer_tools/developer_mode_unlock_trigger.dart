import 'package:flutter/material.dart';
import 'package:example/core/config/app_config.dart';
import 'package:example/core/config/di_module/init_config.dart';
import 'package:example/core/developer_tools/developer_mode_notifier.dart';
import 'package:example/core/developer_tools/developer_pin_gate.dart';
import 'package:example/core/developer_tools/developer_unlock_service.dart';
import 'package:example/presentation/components/snackbar_widget.dart';

/// Wraps [child] with the hidden developer-mode unlock gesture: tap it
/// [DeveloperUnlockService.requiredTaps] times within the timeout window to
/// enable developer mode (behind a PIN gate on prod/staging).
class DeveloperModeUnlockTrigger extends StatelessWidget {
  const DeveloperModeUnlockTrigger({super.key, required this.child});

  final Widget child;

  Future<void> _onTap(BuildContext context) async {
    if (!getIt<DeveloperUnlockService>().registerTap()) return;

    final notifier = getIt<DeveloperModeNotifier>();
    if (notifier.isEnabled) return;

    if (AppConfig.isProd || AppConfig.isStaging) {
      final verified = await verifyDeveloperPin(context);
      if (!verified) return;
    }

    notifier.enable();
    if (!context.mounted) return;
    showCustomSnackBar(context, 'Developer mode enabled', SnackBarType.success);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () => _onTap(context), child: child);
  }
}
