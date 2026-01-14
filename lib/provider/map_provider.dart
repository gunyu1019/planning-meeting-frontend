import 'package:flutter_riverpod/legacy.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import '../model/place_category.dart';


class MapController {
  Future<void> Function(PlaceCategory iconType, void Function(LatLng position, Poi poi) onPoiAdded)? _onAddPoi;
  Future<void> Function(String poiId, PlaceCategory iconPath)? _onModifyPoi;
  Future<void> Function(String poiId)? _onRemovePoi;

  Future<void> onAddPoi(PlaceCategory iconType, void Function(LatLng position, Poi poi) onPoiAdded) async => await _onAddPoi?.call(iconType, onPoiAdded);
  Future<void> onModifyPoi(String poiId, PlaceCategory iconPath) async => await _onModifyPoi?.call(poiId, iconPath);
  Future<void> onRemovePoi(String poiId) async => await _onRemovePoi?.call(poiId);

  void attach({
    Future<void> Function(PlaceCategory iconType, void Function(LatLng position, Poi poi) onPoiAdded)? onAddPoi,
    Future<void> Function(String poiId, PlaceCategory iconType)? onModifyPoi,
    Future<void> Function(String poiId)? onRemovePoi
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


// 카카오맵을 혹시나.. 다룰까??
final kakaoMapControllerProvider = StateProvider<KakaoMapController?>((ref) => null);
final mapControllerProvider = StateProvider((ref) => MapController());