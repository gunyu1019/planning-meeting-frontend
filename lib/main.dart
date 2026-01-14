import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:planning_meeting/provider/travel_editor_provider.dart';
import 'package:planning_meeting/screen/travel_editor.dart';
import 'package:planning_meeting/services/ibm_cloud_service.dart';

void main() async {
  // main() 함수를 비동기로 실행시키기 위해서는 WidgetsFlutterBinding.ensureInitialized(); 함수를 호출해야 합니다.
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'assets/config/.env');
  await KakaoMapSdk.instance.initialize(dotenv.env['KAKAO_API_KEY']!);

  final instanceUrl = dotenv.env['IBM_CLOUD_INSTANCE_URL']!;
  final agentId = dotenv.env['IBM_WATSONX_ORCHESTRATE_AGENT_ID']!;
  final environmentId = dotenv.env['IBM_WATSONX_ORCHESTRATE_ENVIRONMENT_ID']!;

  final ibmCloud = IBMCloud(dotenv.env['IBM_CLOUD_API_KEY']!);
  final ibmWatsonX = await ibmCloud.getWatsonX(instanceUrl);

  // TEST
  // ibmWatsonX.chat(agentId: agentId, environmentId: environmentId, message: "너는 무엇을 할 수 있어?").then((message) => debugPrint(message.content));

  runApp(
    ProviderScope(
      overrides: [
        ibmCloudProvider.overrideWithValue(ibmCloud),
        ibmWatsonXProvider.overrideWithValue(ibmWatsonX),
        ibmChatAgent.overrideWithValue((content, [threadId]) => ibmWatsonX.chat(
                    agentId: agentId,
                    environmentId: environmentId,
                    message: content,
                    threadId: threadId
                )
        )

      ],
      child: MaterialApp(theme: ThemeData(), home: const MainPage()),
    ),
  );
}
