import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ProjectName/core/developer_tools/api_logs/api_log_store.dart';
import 'package:ProjectName/core/developer_tools/developer_mode_notifier.dart';
import 'package:ProjectName/core/http_client/interceptors/api_logger_interceptor.dart';

Response _fakeResponse({int statusCode = 200}) {
  final options = RequestOptions(path: 'https://example.com/feature-flags');
  return Response(
    requestOptions: options,
    statusCode: statusCode,
    data: {'ok': true},
  );
}

void main() {
  test('API log is stored when developer mode is enabled', () {
    final developerMode = DeveloperModeNotifier()..enable();
    final logStore = ApiLogStore();
    final interceptor = ApiLoggerInterceptor(developerMode, logStore);

    interceptor.onResponse(_fakeResponse(), ResponseInterceptorHandler());

    expect(logStore.getLogs(), hasLength(1));
    expect(logStore.getLogs().first.statusCode, 200);
  });

  test('API log is NOT stored when developer mode is disabled', () {
    final developerMode = DeveloperModeNotifier();
    final logStore = ApiLogStore();
    final interceptor = ApiLoggerInterceptor(developerMode, logStore);

    interceptor.onResponse(_fakeResponse(), ResponseInterceptorHandler());

    expect(logStore.getLogs(), isEmpty);
  });

  test('sensitive request headers are masked before storage', () {
    final developerMode = DeveloperModeNotifier()..enable();
    final logStore = ApiLogStore();
    final interceptor = ApiLoggerInterceptor(developerMode, logStore);

    final options = RequestOptions(
      path: 'https://example.com/login',
      headers: {'Authorization': 'Bearer secret-token-123'},
      data: {'password': 'hunter2'},
    );

    interceptor.onResponse(
      Response(requestOptions: options, statusCode: 200, data: {'ok': true}),
      ResponseInterceptorHandler(),
    );

    final entry = logStore.getLogs().first;
    expect(entry.requestHeaders['Authorization'], 'Bearer ****');
    expect((entry.requestBody as Map)['password'], '****');
  });
}
