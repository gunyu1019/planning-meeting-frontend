

import 'package:dio/dio.dart';
import 'package:planning_meeting/model/ibm/ibm_cloud_token.dart';
import 'package:planning_meeting/services/ibm_watsonx_service.dart';

class IBMCloud {
  // IAM (Identity Access Management)에서 발급받은 API Key
  final String __apikey;
  final Dio _dio;

  IBMAuthentic? __cached_iam_token;

  static const baseURL = "https://iam.cloud.ibm.com";

  IBMCloud(String apiKey) : __apikey = apiKey, _dio = Dio(
    BaseOptions(
      baseUrl: baseURL,
      headers: {
        "Accept": "application/json",
        // "Content-Type": "application/json"
      },
      receiveTimeout: const Duration(minutes: 3), // For Stream Connection
      connectTimeout: const Duration(minutes: 3), // For Stream Connection
    )
  );

  /// Generate an IAM Access Token
  Future<IBMAuthentic> identityToken() async {
    final body = 'grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=$__apikey';
    final response = await _dio.post(
        "/identity/token",
        data: body,
        options: Options(contentType: Headers.formUrlEncodedContentType)
    );
    __cached_iam_token = IBMAuthentic.fromJson(response.data);
    return __cached_iam_token!;
  }

  Future<WatsonX> getWatsonX(String instanceUrl) async {
    if (__cached_iam_token == null || DateTime.now().compareTo(__cached_iam_token!.expiration) > 0) {
      await identityToken();
    }
    return WatsonX(__cached_iam_token!, instanceUrl);
  }
}