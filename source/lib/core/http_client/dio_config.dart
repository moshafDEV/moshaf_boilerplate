// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:ProjectName/core/config/app_config.dart';
import 'package:ProjectName/core/http_client/interceptors/custom_interceptor.dart';

void setLoggerInterceptor(Dio dio) {
  dio.interceptors.add(CustomInterceptor());
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 120,
      logPrint: (object) {
        Flavor mode = FlavorConfig.instance.variables["mode"];
        if (mode == Flavor.dev) {
          log(object.toString());
        }
      },
    ),
  );
}

BaseOptions getBaseOptions({required String baseUrl, String? apiKey}) {
  return BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: Duration(milliseconds: 20000),
    sendTimeout: Duration(milliseconds: 20000),
    receiveTimeout: Duration(milliseconds: 20000),
    contentType: "application/json",
    responseType: ResponseType.json,
    headers: apiKey == null ? null : {'X-API-KEY': apiKey},
  );
}
