import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ProjectName/core/config/app_config.dart';
import 'package:ProjectName/core/config/di_module/init_config.dart';
import 'package:ProjectName/core/constants/colors.dart';
import 'package:ProjectName/core/constants/textstyle.dart';
import 'package:ProjectName/core/developer_tools/api_logs/api_log_page.dart';
import 'package:ProjectName/core/developer_tools/api_logs/api_log_store.dart';
import 'package:ProjectName/core/developer_tools/components/developer_menu_parts.dart';
import 'package:ProjectName/core/developer_tools/developer_mode_notifier.dart';
import 'package:ProjectName/core/developer_tools/dialogs/developer_info_dialog.dart';
import 'package:ProjectName/core/developer_tools/dialogs/feature_flags_dialog.dart';
import 'package:ProjectName/core/env/env.dart';
import 'package:ProjectName/core/feature_flags/feature_flag_notifier.dart';

class DeveloperMenuPage extends StatelessWidget {
  const DeveloperMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = getIt<ApiLogStore>();
    return Scaffold(
      backgroundColor: kMainGreySoft2,
      appBar: AppBar(title: const Text('Developer Menu'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _StatusHeader(),
          const SizedBox(height: 20),
          DeveloperMenuSection(
            title: 'Diagnostics',
            tiles: [
              ListenableBuilder(
                listenable: logs,
                builder: (context, _) => DeveloperMenuTile(
                  icon: Icons.list_alt_rounded,
                  iconColor: kMainBlue,
                  title: 'API Logs',
                  subtitle: '${logs.getLogs().length} recorded',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const ApiLogPage()),
                  ),
                ),
              ),
              DeveloperMenuTile(
                icon: Icons.flag_rounded,
                iconColor: kMainInfo,
                title: 'Feature Flags',
                subtitle: 'Inspect current flag values',
                onTap: () => showFeatureFlagsDialog(
                  context,
                  getIt<FeatureFlagNotifier>().state,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DeveloperMenuSection(
            title: 'Actions',
            tiles: [
              DeveloperMenuTile(
                icon: Icons.refresh_rounded,
                iconColor: kMainSuccess,
                title: 'Refresh Remote Config',
                subtitle: 'Re-fetch feature flags from the API',
                onTap: () => _refreshRemoteConfig(context),
              ),
              ListenableBuilder(
                listenable: logs,
                builder: (context, _) => DeveloperMenuTile(
                  icon: logs.errorToastsEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_rounded,
                  iconColor: kMainGrey,
                  title: 'API Error Toasts',
                  subtitle: logs.errorToastsEnabled
                      ? 'On — at most one per 4 s, tap to mute'
                      : 'Muted — errors are still logged, tap to enable',
                  onTap: logs.toggleErrorToasts,
                ),
              ),
              DeveloperMenuTile(
                icon: Icons.delete_sweep_rounded,
                iconColor: kMainWarning,
                title: 'Clear Cache',
                subtitle: 'Clears the in-memory API log cache',
                onTap: () => _clearCache(context),
              ),
              DeveloperMenuTile(
                icon: Icons.power_settings_new_rounded,
                iconColor: kMainDanger,
                title: 'Disable Developer Mode',
                subtitle: 'Hide the debug button until unlocked again',
                onTap: () => _disable(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DeveloperMenuSection(
            title: 'Info',
            tiles: [
              DeveloperMenuTile(
                icon: Icons.info_rounded,
                iconColor: kMainPrimary,
                title: 'App Information',
                subtitle: 'Version, flavor, and API endpoint',
                onTap: () => _showAppInformation(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _refreshRemoteConfig(BuildContext context) async {
    await getIt<FeatureFlagNotifier>().initialize();
    if (!context.mounted) return;
    _showSnack(context, 'Feature flags refreshed', kMainSuccess);
  }

  void _disable(BuildContext context) {
    getIt<DeveloperModeNotifier>().disable();
    Navigator.of(context).pop();
  }

  void _clearCache(BuildContext context) {
    getIt<ApiLogStore>().clear();
    _showSnack(context, 'API log cache cleared', kMainGreyDark);
  }

  Future<void> _showAppInformation(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    if (!context.mounted) return;
    showDeveloperInfoDialog(
      context,
      title: 'App Information',
      icon: Icons.info_rounded,
      iconColor: kMainPrimary,
      rows: {
        'App name': info.appName,
        'Package': info.packageName,
        'Version': '${info.version} (${info.buildNumber})',
        'Flavor': AppConfig.instance.flavor.name,
        'API URL': Env.apiUrl,
      },
    );
  }

  void _showSnack(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kMainPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: kMainSuccess,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Developer Mode Active',
                  style: genStyle14Bold.copyWith(color: kMainWhite),
                ),
                const SizedBox(height: 2),
                Text(
                  'Flavor: ${AppConfig.instance.flavor.name}',
                  style: genStyle12Regular.copyWith(color: kMainGreyLight),
                ),
              ],
            ),
          ),
          const Icon(Icons.bug_report_rounded, color: kMainWhite, size: 28),
        ],
      ),
    );
  }
}
