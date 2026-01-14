import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planning_meeting/provider/travel_editor_provider.dart';
import 'package:planning_meeting/widget/assistant_message_component.dart';

class AssistantChatComponent extends ConsumerStatefulWidget {
  const AssistantChatComponent({super.key});

  @override
  ConsumerState<AssistantChatComponent> createState() =>
      AssistantChatComponentState();
}

class AssistantChatComponentState
    extends ConsumerState<AssistantChatComponent> {
  @override
  Widget build(BuildContext context) {
    final ChatController chatController = ref
        .watch(chatControllerProvider.notifier)
        .state!;

    return Chat(
      builders: Builders(
        textMessageBuilder:
            (
              BuildContext context,
              TextMessage message,
              int index, {
              required bool isSentByMe,
              MessageGroupStatus? groupStatus,
            }) => AssistantMessageComponent(message: message, index: index),
      ),
      chatController: chatController,
      currentUserId: 'user',
      onMessageSend: (text) {
        chatController.insertMessage(
          TextMessage(
            // Better to use UUID or similar for the ID - IDs must be unique
            id: '${Random().nextInt(1000) + 1}',
            authorId: 'user',
            createdAt: DateTime.now().toUtc(),
            text: text,
          ),
        );
      },
      resolveUser: (UserID id) async {
        return User(id: id, name: 'John Doe');
      },
    );
  }
}
