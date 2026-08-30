import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ProjectName/core/constants/colors.dart';
import 'package:ProjectName/core/constants/textstyle.dart';
import 'package:ProjectName/core/developer_tools/api_logs/api_log_model.dart';

const _jsonEncoder = JsonEncoder.withIndent('  ');

String _prettyPrint(dynamic value) {
  if (value == null) return '(empty)';
  if (value is String) return value;
  try {
    return _jsonEncoder.convert(value);
  } catch (_) {
    return value.toString();
  }
}

class ApiLogDetailPage extends StatelessWidget {
  final ApiLogEntry log;

  const ApiLogDetailPage({required this.log, super.key});

  void _copyResponse(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _prettyPrint(log.responseBody)));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Response copied'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainGreySoft2,
      appBar: AppBar(
        title: Text(log.method, overflow: TextOverflow.ellipsis),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy response',
            onPressed: () => _copyResponse(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(log.url, style: genStyle14Medium),
          const SizedBox(height: 10),
          _StatusRow(log: log),
          const SizedBox(height: 20),
          const _SectionTitle('Request Headers'),
          _CodeBlock(_prettyPrint(log.requestHeaders)),
          const SizedBox(height: 16),
          const _SectionTitle('Request Body'),
          _CodeBlock(_prettyPrint(log.requestBody)),
          const SizedBox(height: 16),
          _SectionTitle(log.errorMessage != null ? 'Error' : 'Response Body'),
          _CodeBlock(_prettyPrint(log.errorMessage ?? log.responseBody)),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final ApiLogEntry log;
  const _StatusRow({required this.log});

  @override
  Widget build(BuildContext context) {
    final statusColor = log.isError ? kMainDanger : kMainSuccess;
    final statusText = log.statusCode?.toString() ?? 'ERROR';

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            statusText,
            style: genStyle12Bold.copyWith(color: kMainWhite),
          ),
        ),
        Text('${log.duration.inMilliseconds}ms',
            style: genStyle12Regular.copyWith(color: kMainGrey)),
        Text('·', style: genStyle12Regular.copyWith(color: kMainGreyLight)),
        Text(log.timestamp.toIso8601String(),
            style: genStyle12Regular.copyWith(color: kMainGrey)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: genStyle14Bold);
  }
}

class _CodeBlock extends StatelessWidget {
  final String text;
  const _CodeBlock(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: kMainWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kMainGreySoft),
      ),
      child: SelectableText(
        text,
        style: genStyle12Regular.copyWith(fontFamily: 'monospace'),
      ),
    );
  }
}
