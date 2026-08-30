import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:ProjectName/core/config/app_config.dart';
import 'package:ProjectName/core/config/di_module/init_config.dart';
import 'package:ProjectName/core/constants/colors.dart';
import 'package:ProjectName/core/constants/textstyle.dart';
import 'package:ProjectName/core/developer_tools/api_logs/api_log_page.dart';
import 'package:ProjectName/core/developer_tools/api_logs/api_log_store.dart';
import 'package:ProjectName/core/developer_tools/dialogs/developer_info_dialog.dart';
import 'package:ProjectName/core/developer_tools/dialogs/feature_flags_dialog.dart';
import 'package:ProjectName/core/env/env.dart';
import 'package:ProjectName/core/feature_flags/feature_flag_notifier.dart';

class DeveloperMenuPage extends StatelessWidget {
  const DeveloperMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainGreySoft2,
      appBar: AppBar(
        title: const Text('Developer Menu'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _StatusHeader(),
          const SizedBox(height: 20),
          _MenuSection(
            title: 'Diagnostics',
            tiles: [
              _MenuTile(
                icon: Icons.list_alt_rounded,
                iconColor: kMainBlue,
                title: 'API Logs',
                subtitle:
                    '${context.watch<ApiLogStore>().getLogs().length} recorded',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ApiLogPage()),
                ),
              ),
              _MenuTile(
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
          _MenuSection(
            title: 'Actions',
            tiles: [
              _MenuTile(
                icon: Icons.refresh_rounded,
                iconColor: kMainSuccess,
                title: 'Refresh Remote Config',
                subtitle: 'Re-fetch feature flags from the API',
                onTap: () => _refreshRemoteConfig(context),
              ),
              _MenuTile(
                icon: Icons.delete_sweep_rounded,
                iconColor: kMainWarning,
                title: 'Clear Cache',
                subtitle: 'Clears the in-memory API log cache',
                onTap: () => _clearCache(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _MenuSection(
            title: 'Info',
            tiles: [
              _MenuTile(
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
        borderRadius: BorderRadius.circular(16),
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
                Text('Developer Mode Active',
                    style: genStyle14Bold.copyWith(color: kMainWhite)),
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

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuTile> tiles;

  const _MenuSection({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: genStyle12Bold.copyWith(color: kMainGrey, letterSpacing: 0.5),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: kMainWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kMainGreyDark.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                tiles[i],
                if (i != tiles.length - 1)
                  const Divider(height: 1, indent: 68, color: kMainGreySoft),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: genStyle14Medium),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: genStyle12Regular.copyWith(color: kMainGrey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: kMainGreyLight),
          ],
        ),
      ),
    );
  }
}
