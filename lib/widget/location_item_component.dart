import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:planning_meeting/model/location.dart';
import 'package:planning_meeting/model/place_category.dart';
import 'package:planning_meeting/provider/travel_editor_provider.dart';

class LocationItemComponent extends ConsumerStatefulWidget {
  LocationModel location;
  void Function()? onRemoveButtonEvent;

  LocationItemComponent({super.key, required this.location, this.onRemoveButtonEvent});

  @override
  ConsumerState<LocationItemComponent> createState() => LocationItemComponentState();
}

class LocationItemComponentState extends ConsumerState<LocationItemComponent> {
  bool isEditing = false;
  late final FocusNode focusNode;
  late final TextEditingController textEditorController;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    textEditorController = TextEditingController(text: widget.location.name);
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    textEditorController.dispose();
  }

  Widget leading() => PopupMenuButton<int>(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    offset: const Offset(0, 45),
    tooltip: "아이콘 변경",

    // 현재 선택된 이미지 보여주기
    child: Padding(
      padding: const EdgeInsets.all(4.0), // 이미지라 여백 살짝 조절
      child: Image.asset(
        "assets/image/${widget.location.category.name}.png", // 리스트에서 경로 가져옴
        width: 29, // 이미지 크기 고정 (중요!)
        height: 36,
        fit: BoxFit.contain, // 비율 유지
      ),
    ),

    // 팝업 메뉴 (이미지 선택창)
    itemBuilder: (context) {
      return [
        PopupMenuItem(
          enabled: false,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: PlaceCategory.values.map((category) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      widget.location.category = category;
                      ref.read(mapControllerProvider.notifier).state.onModifyPoi(widget.location.id, category);
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      // 선택된 이미지는 파란 동그라미 배경 표시
                      color: widget.location.category == category
                          ? Colors.blueAccent.shade200
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: widget.location.category == category
                        ? Border.all(color: Colors.blueAccent, width: 2)
                        : null,
                    ),
                    // 팝업 안의 이미지들
                    child: Image.asset(
                      "assets/image/${category.name}.png",
                      width: 29,
                      height: 36,
                      fit: BoxFit.contain
                    ),
                  ),
                );
              }).toList(),
          ),
        ),
      ];
    },
  );

  Widget title() => isEditing
        ? TextField(
            controller: textEditorController, // 각 줄마다 전용 컨트롤러 연결
            decoration: const InputDecoration(
              // 밑줄이나 테두리를 없애서 그냥 텍스트처럼 보이게 함
              border: InputBorder.none,
              hintText: "장소를 입력하세요",
              isDense: true, // 여백을 줄여서 더 콤팩트하게
            ),
            style: const TextStyle(fontSize: 16), // 글자 크기 조정
            // 입력이 끝났을 때(엔터) 처리할 로직이 있다면 여기에 작성
            onSubmitted: (value) {
              widget.location.name = value;
            },
          )
        : GestureDetector(
            // 수정 모드가 아닐 때 텍스트를 누르면?
            onTap: () {
              final newCameraPosition = CameraUpdate.newCenterPosition(widget.location.position);
              final cameraAnimation = CameraAnimation(1000);
              ref.read(kakaoMapControllerProvider.notifier).state?.moveCamera(newCameraPosition, animation: cameraAnimation);
            },
            child: Text(
              textEditorController.text, // 현재 저장된 텍스트 보여주기
              style: const TextStyle(fontSize: 16),
            ),
          );

  Widget trailing() => Row(
      mainAxisSize: MainAxisSize.min, // [중요] 내용물 크기만큼만 공간 차지하게 설정
      children: isEditing
          ? [
              IconButton(
                alignment: AlignmentDirectional.center,
                icon: const Icon(Icons.close, color: Colors.redAccent),
                onPressed: () {
                  setState(() => isEditing = false);
                },
              ),
              IconButton(
                alignment: AlignmentDirectional.center,
                icon: const Icon(Icons.check, color: Colors.greenAccent),
                onPressed: () {
                  setState(() {
                    widget.location.name = textEditorController.text;
                    setState(() => isEditing = false);
                  });
                },
              ),
            ]
          : [
              IconButton(
                alignment: AlignmentDirectional.center,
                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                onPressed: () {
                  setState(() => isEditing = true);
                },
              ),
              IconButton(
                alignment: AlignmentDirectional.center,
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  ref.read(mapControllerProvider.notifier).state.onRemovePoi(widget.location.id);
                  widget.onRemoveButtonEvent?.call();
                },
              ),
            ],
    );

  @override
  Widget build(BuildContext context) => ListTile(
    leading: leading(),
    title: title(),
    dense: true,
    trailing: trailing(),
  );
}
