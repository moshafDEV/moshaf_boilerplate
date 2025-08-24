import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:ProjectName/core/env/env.dart';

import 'dio_config.dart';

class MainClient with DioMixin implements Dio {
  MainClient() {
    options = getBaseOptions(baseUrl: Env.apiUrl);
    httpClientAdapter = IOHttpClientAdapter();
    setLoggerInterceptor(this);
    // setFirebasePerformanceInterceptor(this);
  }
}
