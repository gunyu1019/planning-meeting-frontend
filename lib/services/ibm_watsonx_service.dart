import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:planning_meeting/model/ibm/ibm_cloud_token.dart';

import '../model/agent_message.dart';

class WatsonX {
  // IAM (Identity Access Management)에서 발급받은 API Key
  final IBMAuthentic __accessToken;
  final Dio _dio;

  final String instanceUrl;

  WatsonX(IBMAuthentic accessToken, this.instanceUrl) :
        __accessToken = accessToken,
        _dio = Dio(
          BaseOptions(
            baseUrl: instanceUrl,
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json"
          })
        ) {
    _dio.options.headers["Authorization"] = __accessToken.toString();
  }

  Future<Map<String, dynamic>> _getSpecificRun(String runId) async {
    final response = await _dio.get("/v1/orchestrate/runs/$runId");
    return response.data;
  }

  Future<String> _createRun({
    String? agentId,
    String? environmentId,
    String? message,
    String? threadId,
    // Map<String, dynamic>? additionalParameters,
    // Map<String, dynamic>? context,
    // Map<String, dynamic>? contextVariables,
    bool stream = true,
    int max_timeout = 180000,
    bool multipleContent = true,
    // dynamic? guardrails,
    // dynamic? llm_params
  }) async {
    final parameter = {
      "stream": stream,
      "stream_timeout": max_timeout,
      "multipleContent": multipleContent
    };
    final data = {
      "agent_id": agentId,
      "environment_id": environmentId,
      "message": {
        "role": "user",
        "response_type": "text",
        "content": message
      },
      "thread_id": threadId
    };

    if (stream) {
      final response = await _dio.post<ResponseBody>(
          "/v1/orchestrate/runs",
          queryParameters: parameter,
          data: data,
          options: Options(responseType: ResponseType.stream)
      );
      Stream<List<int>> stream = response.data!.stream;

      // wait!
      List<int> lastChunk = await stream.last;

      String rawData = utf8.decode(lastChunk);
      String jsonRawData = '[${rawData.replaceAll("}\n", "},\n")}]'.replaceAll("},\n]", "}\n]");
      List<dynamic> result = json.  decode(jsonRawData);
      return result.last["data"]["run_id"];
    }
    final response = await _dio.post(
        "/v1/orchestrate/runs",
        queryParameters: parameter,
        data: data,
        options: Options(responseType: ResponseType.json)
    );
    return response.data["run_id"];
  }

  /// IBM WatsonX Orchestrate Agent와 채팅을 주고 받습니다.
  /// [threadId]를 입력하지 않으면 새로운 채팅창을 개설하여 Agent에게 메시지를 주고 응답을 받습니다.
  Future<AgentMessage> chat({
    required String agentId,
    required String environmentId,
    required String message,
    String? threadId
  }) async {
    final runId = await _createRun(
      agentId: agentId,
      environmentId: environmentId,
      message: message,
      threadId: threadId,
      stream: true
    );
    final taskResult = await _getSpecificRun(runId);
    final agentResult = taskResult["result"]["data"]["message"];

    final agentMessage = AgentMessage(
      agentResult["id"],
      agentResult["role"],
      taskResult["thread_id"],
      taskResult["tenant_id"],
      DateTime.parse(agentResult["created_on"]),
      agentResult["content"][0]["text"]
    );
    return agentMessage;
  }
}