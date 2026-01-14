import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planning_meeting/services/ibm_cloud_service.dart';
import 'package:planning_meeting/services/ibm_watsonx_service.dart';


final ibmCloudProvider = Provider<IBMCloud?>((ref) => null);
final ibmWatsonXProvider = Provider<WatsonX?>((ref) => null);
