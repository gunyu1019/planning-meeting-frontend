import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import '../model/place_category.dart';
import '../services/ibm_cloud_service.dart';
import '../services/ibm_watsonx_service.dart';

class MapController {
  Future<void> Function(
    PlaceCategory iconType,
    void Function(LatLng position, Poi poi) onPoiAdded,
  )?
  _onAddPoi;
  Future<void> Function(String poiId, PlaceCategory iconPath)? _onModifyPoi;
  Future<void> Function(String poiId)? _onRemovePoi;

  Future<void> onAddPoi(
    PlaceCategory iconType,
    void Function(LatLng position, Poi poi) onPoiAdded,
  ) async => await _onAddPoi?.call(iconType, onPoiAdded);
  Future<void> onModifyPoi(String poiId, PlaceCategory iconPath) async =>
      await _onModifyPoi?.call(poiId, iconPath);
  Future<void> onRemovePoi(String poiId) async =>
      await _onRemovePoi?.call(poiId);

  void attach({
    Future<void> Function(
      PlaceCategory iconType,
      void Function(LatLng position, Poi poi) onPoiAdded,
    )?
    onAddPoi,
    Future<void> Function(String poiId, PlaceCategory iconType)? onModifyPoi,
    Future<void> Function(String poiId)? onRemovePoi,
  }) {
    _onAddPoi = onAddPoi ?? onAddPoi;
    _onModifyPoi = onModifyPoi ?? _onModifyPoi;
    _onRemovePoi = onRemovePoi ?? _onRemovePoi;
  }

  void detach() {
    _onAddPoi = null;
    _onModifyPoi = null;
    _onRemovePoi = null;
  }
}

class MenuControllerNotifier extends StateNotifier<String> {
  MenuControllerNotifier() : super("setup");

  void changePage(String pageId) => state = pageId;
}

final menuControllerProvider =
    StateNotifierProvider<MenuControllerNotifier, String>(
      (ref) => MenuControllerNotifier(),
    );

// 카카오맵을 혹시나.. 다룰까??
final kakaoMapControllerProvider = StateProvider<KakaoMapController?>(
  (ref) => null,
);
final mapControllerProvider = StateProvider((ref) => MapController());

final ibmCloudProvider = Provider<IBMCloud?>((ref) => null);
final ibmWatsonXProvider = Provider<WatsonX?>((ref) => null);

final chatControllerProvider = StateProvider<ChatController?>(
  (ref) => InMemoryChatController(),
);
