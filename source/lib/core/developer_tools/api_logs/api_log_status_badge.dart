import 'package:flutter/material.dart';
import 'package:ProjectName/core/constants/colors.dart';
import 'package:ProjectName/core/constants/textstyle.dart';
import 'package:ProjectName/core/developer_tools/api_logs/api_log_model.dart';

/// Status code (or ERR) on a green/red background.
class ApiStatusBadge extends StatelessWidget {
  const ApiStatusBadge({super.key, required this.log});

  final ApiLogEntry log;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: log.isError ? kMainDanger : kMainSuccess,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        log.statusCode?.toString() ?? 'ERR',
        style: genStyle12Bold.copyWith(color: kMainWhite),
      ),
    );
  }
}

/// Method HTTP berwarna (GET biru, POST hijau, PUT/PATCH kuning, DELETE merah).
class ApiMethodBadge extends StatelessWidget {
  const ApiMethodBadge({super.key, required this.method});

  final String method;

  @override
  Widget build(BuildContext context) {
    final color = switch (method.toUpperCase()) {
      'GET' => kMainBlue,
      'POST' => kMainSuccess,
      'PUT' || 'PATCH' => kMainWarning,
      'DELETE' => kMainDanger,
      _ => kMainGrey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(method, style: genStyle12Bold.copyWith(color: color)),
    );
  }
}
