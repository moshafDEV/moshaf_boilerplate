import 'package:injectable/injectable.dart';
import 'package:ProjectName/core/constants/api_path_constant.dart';
import 'package:ProjectName/core/http_client/main_client.dart';

/// Raw HTTP call only — no parsing, no fallback. Errors (DioException,
/// timeouts) propagate to the caller (FeatureFlagRepositoryImpl) to handle.
@lazySingleton
class FeatureFlagApi {
  final MainClient _client;

  FeatureFlagApi(this._client);

  Future<Map<String, dynamic>> fetchFeatureFlags() async {
    final response = await _client.get(ApiPath.UFeatureFlags);
    return response.data as Map<String, dynamic>;
  }
}
