import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:example/core/config/app_config.dart';
import 'package:example/core/config/di_module/init_config.dart';
import 'package:example/core/constants/colors.dart';
import 'package:example/core/constants/textstyle.dart';
import 'package:example/core/developer_tools/developer_mode_notifier.dart';
import 'package:example/core/developer_tools/developer_pin_gate.dart';
import 'package:example/core/developer_tools/developer_unlock_service.dart';
import 'package:example/presentation/components/snackbar_widget.dart';

/// Hosts the hidden developer-mode unlock gesture (tap the version 7 times)
/// — see DeveloperModeNotifier for what "enabled" then does app-wide.
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final _unlockService = getIt<DeveloperUnlockService>();
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _packageInfo = info);
    });
  }

  Future<void> _onVersionTap() async {
    if (!_unlockService.registerTap()) return;
    await _unlockDeveloperMode();
  }

  Future<void> _unlockDeveloperMode() async {
    final notifier = getIt<DeveloperModeNotifier>();
    if (notifier.isEnabled) return;

    if (AppConfig.isProd) {
      final verified = await verifyDeveloperPin(context);
      if (!verified) return;
    }

    notifier.enable();
    if (!mounted) return;
    showCustomSnackBar(context, 'Developer mode enabled', SnackBarType.success);
  }

  @override
  Widget build(BuildContext context) {
    final info = _packageInfo;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 48, color: kMainPrimary),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _onVersionTap,
              child: Text(
                info == null
                    ? 'Loading version…'
                    : 'Version ${info.version} (${info.buildNumber})',
                style: genStyle14Medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
