import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:example/core/constants/colors.dart';
import 'package:example/core/constants/textstyle.dart';
import 'package:example/core/developer_tools/api_logs/api_log_detail_page.dart';
import 'package:example/core/developer_tools/api_logs/api_log_model.dart';
import 'package:example/core/developer_tools/api_logs/api_log_status_badge.dart';
import 'package:example/core/developer_tools/api_logs/api_log_store.dart';

class ApiLogPage extends StatelessWidget {
  const ApiLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ApiLogStore>();
    final logs = store.getLogs();

    return Scaffold(
      backgroundColor: kMainGreySoft2,
      appBar: AppBar(
        title: Text('API Logs (${logs.length})'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear logs',
            onPressed: logs.isEmpty ? null : store.clear,
          ),
        ],
      ),
      body: logs.isEmpty ? const _EmptyState() : _LogList(logs: logs),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_rounded, size: 48, color: kMainGreyLight),
          const SizedBox(height: 12),
          Text(
            'No API calls recorded yet',
            style: genStyle14Medium.copyWith(color: kMainGrey),
          ),
        ],
      ),
    );
  }
}

class _LogList extends StatelessWidget {
  final List<ApiLogEntry> logs;
  const _LogList({required this.logs});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _ApiLogTile(log: logs[index]),
    );
  }
}

String _timeOfDay(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

class _ApiLogTile extends StatelessWidget {
  final ApiLogEntry log;
  const _ApiLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kMainWhite,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => ApiLogDetailPage(log: log))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ApiMethodBadge(method: log.method),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Uri.tryParse(log.url)?.path ?? log.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: genStyle14Medium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_timeOfDay(log.timestamp)} · ${log.duration.inMilliseconds}ms',
                      style: genStyle12Regular.copyWith(color: kMainGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ApiStatusBadge(log: log),
            ],
          ),
        ),
      ),
    );
  }
}
