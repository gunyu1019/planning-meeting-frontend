import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planning_meeting/widget/location_item_component.dart';
import 'package:planning_meeting/model/location.dart';
import 'package:planning_meeting/provider/travel_editor_provider.dart';

import '../model/place_category.dart';

class SetupComponent extends ConsumerStatefulWidget {
  const SetupComponent({super.key});

  @override
  ConsumerState<SetupComponent> createState() => SetupComponentState();
}

class SetupComponentState extends ConsumerState<SetupComponent> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  bool _isLoading = false;

  // Agent AI로 보낼 여러 변수들~
  DateTime? tripStartTime;
  DateTime? tripEndTime;
  LocationModel? tripHotelLocation;
  LocationModel? tripMeetingLocation;
  List<LocationModel> wishToVisit = [];

  Future<void> _selectDateTime(
    BuildContext context,
    void Function(DateTime date, TimeOfDay time) onChoose,
  ) async {
    // 1. 날짜 선택
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return; // 날짜를 취소하면 종료

    // 2. 시간 선택 (날짜 선택 후 바로 실행됨)
    if (!context.mounted) return; // 비동기 작업 후 context 유효성 체크
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      onChoose(pickedDate, pickedTime);
    }
  }

  Widget survey(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 8.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- 0. 여행 제목 ----------------
          const Text(
            '여행 제목',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const TextField(
            decoration: InputDecoration(
              hintText: '이번에는 여행은 무슨 여행일까요?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),

          // ---------------- 1. 여행 기간 ----------------
          const Text(
            '여행 기간',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _startDateController, // 컨트롤러 연결
                  readOnly: true, // 타이핑 방지 (오타 방지)
                  onTap: () => _selectDateTime(context, (date, time) {
                    tripStartTime = date.copyWith(
                      hour: time.hour,
                      minute: time.minute,
                    );
                    setState(() {
                      // 3. 날짜와 시간을 합쳐서 "YYYY-MM-DD HH:mm" 형식으로 표시
                      final String dateStr =
                          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                      final String timeStr =
                          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

                      _startDateController.text = "$dateStr $timeStr";
                    });
                  }), // 클릭 시 달력 뜸
                  decoration: const InputDecoration(
                    hintText: '시작 일시',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    suffixIcon: Icon(Icons.calendar_today, size: 20), // 달력 아이콘
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('~', style: TextStyle(fontSize: 20)),
              ),
              Expanded(
                child: TextField(
                  controller: _endDateController, // 컨트롤러 연결
                  readOnly: true, // 타이핑 방지 (오타 방지)
                  onTap: () => _selectDateTime(context, (date, time) {
                    tripEndTime = date.copyWith(
                      hour: time.hour,
                      minute: time.minute,
                    );
                    setState(() {
                      // 3. 날짜와 시간을 합쳐서 "YYYY-MM-DD HH:mm" 형식으로 표시
                      final String dateStr =
                          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                      final String timeStr =
                          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

                      _endDateController.text = "$dateStr $timeStr";
                    });
                  }), // 클릭 시 달력 뜸
                  decoration: const InputDecoration(
                    hintText: '종료 일시',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    suffixIcon: Icon(Icons.calendar_today, size: 20), // 달력 아이콘
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ---------------- 2. 방문해보고 싶은 장소 ----------------
          Column(
            children: [
              Row(
                spacing: 2.0,
                children: [
                  const Text(
                    '방문해보고 싶은 장소',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(child: SizedBox.shrink()),
                  IconButton(
                    onPressed: () {
                      _showComment("방문해보고 싶은 장소를 클릭해주세요!");
                      ref.read(mapControllerProvider.notifier).state.onAddPoi(
                        PlaceCategory.tourism,
                        (position, poi) {
                          final tempName =
                              "나는 여길 가보고 싶어! (${wishToVisit.length + 1})";
                          setState(() {
                            wishToVisit.add(
                              LocationModel(
                                id: poi.id,
                                name: tempName,
                                position: position,
                                category: PlaceCategory.tourism,
                              ),
                            );
                          });
                          _showComment("방문하고 싶은 장소가 등록되었습니다.");
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.add_circle,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ListView 영역 (임시로 높이 지정 및 테두리 표시)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: wishToVisit.isEmpty
                  ? addComment('+ 버튼을 클릭하여 가보고 싶은 장소를 작성하세요.')
                  : ListView.builder(
                      itemCount: wishToVisit.length, // 예시 아이템 3개
                      itemBuilder: (context, index) => LocationItemComponent(
                        location: wishToVisit[index],
                        onRemoveButtonEvent: () {
                          _showComment("${wishToVisit[index].name}가 삭제되었습니다.");
                          setState(() {
                            wishToVisit.removeAt(index);
                          });
                        },
                      ),
                    ),
            ),
          ),

          // ---------------- 3. 모이는 장소 ----------------
          Row(
            spacing: 2.0,
            children: [
              const Text(
                '집합 장소',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Expanded(child: SizedBox.shrink()),
              IconButton(
                onPressed: tripMeetingLocation != null
                    ? null
                    : () {
                        _showComment("집합 장소를 지도에서 클릭해주세요!");
                        ref.read(mapControllerProvider.notifier).state.onAddPoi(
                          PlaceCategory.hotel,
                          (position, poi) {
                            setState(() {
                              tripMeetingLocation = LocationModel(
                                id: poi.id,
                                name: "집합 장소",
                                position: position,
                                category: PlaceCategory.hotel,
                              );
                            });
                            _showComment("집합 장소를 등록되었습니다.");
                          },
                        );
                      },
                icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
              ),
            ],
          ),
          SizedBox(
            height: 36,
            child: tripMeetingLocation == null
                ? addComment("+ 버튼을 클릭하여 여정이 시작되는 장소를 등록해보세요!")
                : LocationItemComponent(
                    location: tripMeetingLocation!,
                    onRemoveButtonEvent: () {
                      setState(() {
                        tripMeetingLocation = null;
                      });
                      _showComment("집합 장소가 삭제되었습니다.");
                    },
                  ),
          ),
          const SizedBox(height: 16),

          // ---------------- 4. 호텔 ----------------
          Row(
            spacing: 2.0,
            children: [
              const Text(
                '숙박하는 장소',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Expanded(child: SizedBox.shrink()),
              IconButton(
                onPressed: tripHotelLocation == null
                    ? () {
                        _showComment("숙박하는 장소를 지도에서 클릭해주세요!");
                        ref.read(mapControllerProvider.notifier).state.onAddPoi(
                          PlaceCategory.hotel,
                          (position, poi) {
                            setState(() {
                              tripHotelLocation = LocationModel(
                                id: poi.id,
                                name: "호텔",
                                position: position,
                                category: PlaceCategory.hotel,
                              );
                            });
                            _showComment("숙소가 등록되었습니다.");
                          },
                        );
                      }
                    : null,
                icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
              ),
            ],
          ),
          SizedBox(
            height: 36,
            child: tripHotelLocation == null
                ? addComment("+ 버튼을 클릭하여 숙박하는 장소를 등록해보세요!")
                : LocationItemComponent(
                    location: tripHotelLocation!,
                    onRemoveButtonEvent: () {
                      setState(() {
                        tripHotelLocation = null;
                      });
                      _showComment("숙박 장소가 삭제되었습니다.");
                    },
                  ),
          ),

          const SizedBox(height: 16),
          // ---------------- 5. 계획하기 버튼 ----------------
          SizedBox(
            width: double.infinity, // 가로 꽉 채우기
            height: 50,
            child: ElevatedButton(
              onPressed: _submitPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '계획하기!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        survey(context),
        if (_isLoading)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black54,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 16.0,
              children: [
                CircularProgressIndicator(
                  color: Colors.blue,
                ),
                Text(
                  "최적의 여행 동선을 구성하고 있습니다!\n잠시만 기다려주세요..!",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                  textAlign: TextAlign.center,
                )
              ]
            ),
          )
      ],
    );
  }

  Widget addComment(comment) => SizedBox(
    width: double.infinity,
    child: Center(
      child: Text(
        comment,
        style: TextStyle(
          fontSize: 12, // 본문보다 작게
          color: Colors.grey, // 회색으로 은은하게
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );

  Future<void> _submitPlan() async {
    if (tripStartTime == null ||
        tripEndTime == null ||
        tripMeetingLocation == null) {
      _showWarning("여행 기간과 집합 장소를 등록해주세요!");
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final payload = {
      "hotel": tripHotelLocation?.toMessage(),
      "meetingPlace": tripMeetingLocation?.toMessage(),
      "meetingStartDate": tripStartTime?.toIso8601String(),
      "meetingEndDate": tripEndTime?.toIso8601String(),
      "wishToVisit": wishToVisit.map((e) => e.toMessage()).toList(),
    };
    final assistantInitialAnswer = await ref.read(ibmChatAgent)?.call(jsonEncode(payload));
    if (assistantInitialAnswer != null) {
      ref.read(messages).add(assistantInitialAnswer);
    }
    ref.read(chatControllerProvider).insertMessage(
      TextMessage(
        // Better to use UUID or similar for the ID - IDs must be unique
        id: '${Random().nextInt(1000) + 1}',
        authorId: 'assistant',
        createdAt: DateTime.now().toUtc(),
        text: assistantInitialAnswer?.content ?? "여행 계획을 불러오는데 실패하였습니다.",
      ),
    );
    ref.read(menuControllerProvider.notifier).changePage("result");
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent, // 경고 느낌이 나게 빨간색으로
        duration: const Duration(seconds: 2), // 2초 뒤에 사라짐
      ),
    );
  }

  void _showComment(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color.fromARGB(255, 50, 50, 50),
        duration: const Duration(seconds: 1), // 1초 뒤에 사라짐
      ),
    );
  }

  @override
  void dispose() {
    // 화면이 종료될 때 메모리 해제
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}
