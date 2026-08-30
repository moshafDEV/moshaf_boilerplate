import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:example/core/constants/colors.dart';
import 'package:example/core/developer_tools/api_logs/api_log_detail_page.dart';
import 'package:example/core/developer_tools/api_logs/api_log_model.dart';
import 'package:example/core/developer_tools/api_logs/api_log_store.dart';
import 'package:example/core/developer_tools/developer_mode_notifier.dart';
import 'package:example/core/developer_tools/developer_navigation.dart';

/// Records every request/response into [logStore] — but only while
/// [developerMode] is enabled, and never retroactively: nothing is ever
/// buffered or stored when developer mode is off. Constructor-injected
/// (not read off `getIt` internally) so this is trivially unit-testable
/// with fake instances of both.
class ApiLoggerInterceptor extends Interceptor {
  final DeveloperModeNotifier developerMode;
  final ApiLogStore logStore;

  ApiLoggerInterceptor(this.developerMode, this.logStore);

  static const _startedAtKey = 'apiLoggerStartedAt';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (developerMode.isEnabled) {
      options.extra[_startedAtKey] = DateTime.now();
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log(
      options: response.requestOptions,
      statusCode: response.statusCode,
      responseBody: response.data,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(
      options: err.requestOptions,
      statusCode: err.response?.statusCode,
      responseBody: err.response?.data,
      errorMessage: err.message ?? err.type.toString(),
    );
    handler.next(err);
  }

  void _log({
    required RequestOptions options,
    int? statusCode,
    dynamic responseBody,
    String? errorMessage,
  }) {
    if (!developerMode.isEnabled) return;

    final startedAt =
        options.extra[_startedAtKey] as DateTime? ?? DateTime.now();
    final entry = ApiLogEntry.from(
      options: options,
      startedAt: startedAt,
      statusCode: statusCode,
      responseBody: responseBody,
      errorMessage: errorMessage,
    );

    logStore.add(entry);

    if (entry.isError) _notifyError(entry);
  }

  /// Success needs no popup — only surfaces >=400 responses and network
  /// errors, tappable straight into the offending log entry.
  void _notifyError(ApiLogEntry entry) {
    final context = rootDeveloperContext();
    if (context == null || !context.mounted) return;

    final message =
        entry.statusCode != null ? 'API Error ${entry.statusCode}' : 'Network error';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: kMainDanger,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View',
          textColor: kMainWhite,
          onPressed: () => pushDeveloperPage(ApiLogDetailPage(log: entry)),
        ),
      ),
    );
  }
}
