import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planning_meeting/widget/setup_component.dart';

import '../provider/menu_provider.dart';
import 'assistant_chat_component.dart' show AssistantChatComponent;

class MenuComponent extends ConsumerStatefulWidget {
  const MenuComponent({super.key});

  @override
  ConsumerState<MenuComponent> createState() => MenuComponentState();
}

class MenuComponentState extends ConsumerState<MenuComponent> {
  // String selectedMenu = 'setup'; // setup or chat

  @override
  Widget build(BuildContext context) {
    final selectedMenu = ref.watch(menuControllerProvider);

    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 버튼 간격 균등 배치
            children: [
              _buildMenuButton('setup', '여정 설정'),
              _buildMenuButton('result', '여행 계획'),
            ],
          ),
        ),

        // Content
        Expanded(
          child: selectedMenu == 'setup'
              ? SetupComponent()
              : AssistantChatComponent(),
        ),
      ],
    );
  }

  // 메뉴 버튼을 만드는 함수 (코드 중복 방지)
  Widget _buildMenuButton(String id, String name) {
    final selectedMenu = ref.watch(menuControllerProvider);

    return TextButton(
      onPressed: () {
        ref.read(menuControllerProvider.notifier).changePage(id);
        // setState(() => selectedMenu = id)
      },
      style: TextButton.styleFrom(
        foregroundColor: selectedMenu == id ? Colors.white : Colors.white54,
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 18,
          fontWeight: selectedMenu == id ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
