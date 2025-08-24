import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ProjectName/core/env/secure_storage_key.dart';
import 'package:ProjectName/core/utils/storage_data.dart';

class CustomInterceptor extends Interceptor {
  final Stopwatch _stopwatch = Stopwatch();
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Do something before request is sent

    // Add bearer token to the request headers if available
    final accessToken = await SecureStorageUtils.getStorage(bearerToken);
    if (accessToken.isNotEmpty) {
      options.headers['Authorization'] = "bearer $accessToken";
      debugPrint('Access token $accessToken');
    } else {
      options.headers.remove('Authorization');
      debugPrint('Authorization header removed');
    }

    // Add language code to the request headers if available
    final langCode = await SecureStorageUtils.getStorage(localeLangId);
    if (langCode.isNotEmpty) {
      options.headers['X-Localization'] = langCode;
      debugPrint('Language code $langCode');
    } else {
      options.headers.remove('X-Localization');
    }

    _stopwatch.reset();
    _stopwatch.start();
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    _stopwatch.stop();
    debugPrint(
      'Request to ${response.realUri} completed in ${_stopwatch.elapsedMilliseconds}ms',
    );
    if (response.statusCode! >= 200 && response.statusCode! < 300) {}
    // if response is 401 or 403, we can navigate to login page
    if (response.statusCode == 401 || response.statusCode == 403) {
      // prefs.clear();

      // await clearStorage();
      // httpService.dio.options.headers.remove('Authorization');

      // showDialog(
      //     context: locator<NavigationService>().navigatorKey.currentContext!,
      //     builder: (context) {
      //       return Dialog(
      //         child: ElevatedButton(
      //           child: const Text("Session Expired, please relogin"),
      //           onPressed: () {
      //             locator<NavigationService>().clearAndNavigateTo(Paths.bottomNavBar);
      //           },
      //         ),
      //       );
      //     });

      // opencommmmmm
      // locator<NavigationService>().clearAndNavigateTo(Paths.bottomNavBar);
    }
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      // if (!err.requestOptions.path.contains('change-password')) {
      // }
      return super.onError(err, handler);
    }

    if (err.error.toString().contains('CERTIFICATE_VERIFY_FAILED')) {
      final customError = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: err.error,
        message:
            'SSL certificate verification failed. Please check your connection.',
      );
      return super.onError(customError, handler);
    }

    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      final customError = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: err.error,
        message:
            'No internet connection detected. Please check your network and try again.',
      );

      return super.onError(customError, handler);
    } else {
      return super.onError(err, handler);
    }
  }
}
