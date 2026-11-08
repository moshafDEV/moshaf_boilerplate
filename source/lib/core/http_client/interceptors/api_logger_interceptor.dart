import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ProjectName/core/constants/colors.dart';
import 'package:ProjectName/core/developer_tools/api_logs/api_log_detail_page.dart';
import 'package:ProjectName/core/developer_tools/api_logs/api_log_model.dart';
import 'package:ProjectName/core/developer_tools/api_logs/api_log_store.dart';
import 'package:ProjectName/core/developer_tools/api_logs/error_toast_throttle.dart';
import 'package:ProjectName/core/developer_tools/developer_mode_notifier.dart';
import 'package:ProjectName/core/developer_tools/developer_navigation.dart';

/// Records every request/response into [logStore] — but only while
/// [developerMode] is enabled, and never retroactively: nothing is ever
/// buffered or stored when developer mode is off. Constructor-injected
/// (not read off `getIt` internally) so this is trivially unit-testable
/// with fake instances of both.
class ApiLoggerInterceptor extends Interceptor {
  final DeveloperModeNotifier developerMode;
  final ApiLogStore logStore;

  ApiLoggerInterceptor(this.developerMode, this.logStore);

  final _toastThrottle = ErrorToastThrottle();

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
  /// errors, tappable straight into the offending log entry. At most one
  /// toast per cooldown (the rest are summarised as "+N more"), it replaces
  /// the one on screen instead of queueing, and it can be muted from the
  /// Developer Menu. Every failure is still logged either way.
  void _notifyError(ApiLogEntry entry) {
    if (!logStore.errorToastsEnabled) return;
    if (!_toastThrottle.allow(DateTime.now())) return;

    final context = rootDeveloperContext();
    if (context == null || !context.mounted) return;

    final more = _toastThrottle.takeSuppressed();
    final base = entry.statusCode != null
        ? 'API Error ${entry.statusCode}'
        : 'Network error';
    final message = more > 0 ? '$base (+$more more)' : base;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
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
