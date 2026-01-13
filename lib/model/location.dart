import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:planning_meeting/model/place_category.dart';

class LocationModel {
  final String id; // poi ID
  String name;
  PlaceCategory category;
  final LatLng position;

  // 생성자: 필수값으로 지정 (required)
  LocationModel({required this.id, required this.name, required this.category, required this.position});

  @override
  String toString() {
    return 'LocationModel(id: $id, name: $name, position: ${position.toString()}, category: $category)';
  }

  Map<String, dynamic> toMessage() => {
    "name": name,
    "latitude": position.latitude,
    "longitude": position.longitude,
    "category": category.name
  };
}
