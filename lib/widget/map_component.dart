import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:planning_meeting/provider/travel_editor_provider.dart';

import '../model/place_category.dart';

class MapComponent extends ConsumerStatefulWidget {
  const MapComponent({super.key});

  @override
  ConsumerState<MapComponent> createState() => MapComponentState();
}

class MapComponentState extends ConsumerState<MapComponent> {
  late KakaoMapController mapController;
  String mapMode = "default"; // default or tracking
  Completer<LatLng>? trackingClick;

  Map<PlaceCategory, PoiStyle> styles = {};

  @override
  void initState() {
    super.initState();
    mapMode = "default";

    ref
        .read(mapControllerProvider.notifier)
        .state
        .attach(
          onAddPoi: onAddPoi,
          onModifyPoi: onModifyPoi,
          onRemovePoi: onRemovePoi,
        );
  }

  Future<void> onAddPoi(
    PlaceCategory poiCategory,
    void Function(LatLng position, Poi poi) onPoiAdded,
  ) async {
    final completer = trackingClick = Completer<LatLng>();
    mapMode = "tracking";
    LatLng position = await completer.future;

    Poi poi = await mapController.labelLayer.addPoi(
      position,
      style: styles[poiCategory]!,
    );
    // PoiStyle poiStyle = PoiStyle(icon: KImage.fromAsset("image/${poiCategory.name}.png", 116, 146));
    // Poi poi = await mapController.labelLayer.addPoi(position, style: poiStyle);

    onPoiAdded.call(position, poi);
  }

  Future<void> onModifyPoi(String poiId, PlaceCategory placeCategory) async {
    Poi? poi = mapController.labelLayer.getPoi(poiId);
    // TEMP: 왜 작동을 안할까요 호호.. 웹 포팅 다시하게 생겼네
    // 사실 안드로이드, iOS 환경에서 Poi를 재정의하면 객체가 완전히 뒤바뀌어서 문제가 되지만
    // 웹 환경에서는 이미지가 바뀌는 그 순간 SDK Poi를 재정의하기 때문에 로직상 큰 문제가 없음.
    // await poi?.changeStyles(styles[placeCategory]!);
    if (poi != null) {
      await poi.remove();
      await mapController.labelLayer.addPoi(
        poi.position,
        style: styles[placeCategory]!,
        id: poiId,
      );
    }
  }

  Future<void> onRemovePoi(String poiId) async {
    Poi? poi = mapController.labelLayer.getPoi(poiId);
    await poi?.remove();
  }

  Future<void> onMapReady(KakaoMapController controller) async {
    ref.read(kakaoMapControllerProvider.notifier).state = mapController =
        controller;

    for (var placeCategory in PlaceCategory.values) {
      final image = KImage.fromAsset("image/${placeCategory.name}.png", 58, 73);
      final style = PoiStyle(icon: image);
      await controller.addPoiStyle(style);
      styles[placeCategory] = style;
    }
  }

  @override
  Widget build(BuildContext context) {
    final option = const KakaoMapOption(
      position: LatLng(37.55401874240999, 126.97071217687956),
    );
    return KakaoMap(
      onMapReady: onMapReady,
      onMapClick: (KPoint point, LatLng position) {
        if (mapMode == "tracking" && trackingClick != null) {
          trackingClick?.complete(position);
          mapMode = "default";
          trackingClick = null;
        }
      },
      option: option,
    );
  }
}
