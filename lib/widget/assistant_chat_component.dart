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

  Future<void> onMessageSend(String text) async {
    ref.read(chatControllerProvider).insertMessage(
      TextMessage(
        // Better to use UUID or similar for the ID - IDs must be unique
        id: '${Random().nextInt(1000) + 1}',
        authorId: 'user',
        createdAt: DateTime.now().toUtc(),
        text: text,
      ),
    );
    final previousThreadId = ref.read(messages).lastOrNull?.threadId;
    final newAnswer = await ref.read(ibmChatAgent)?.call(text, previousThreadId);
    if (newAnswer != null) {
      ref.read(messages).add(newAnswer);
      ref.read(chatControllerProvider).insertMessage(
        TextMessage(
          // Better to use UUID or similar for the ID - IDs must be unique
          id: '${Random().nextInt(1000) + 1}',
          authorId: 'assistant',
          createdAt: DateTime.now().toUtc(),
          text: newAnswer.content,
        ),
      );
    } else {
      ref.read(chatControllerProvider).insertMessage(
        TextMessage(
          // Better to use UUID or similar for the ID - IDs must be unique
          id: '${Random().nextInt(1000) + 1}',
          authorId: 'assistant',
          createdAt: DateTime.now().toUtc(),
          text: "응답을 실패했습니다.",
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    final chatController = ref.watch(chatControllerProvider);

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
      onMessageSend: onMessageSend,
      resolveUser: (UserID id) async {
        return User(id: id, name: 'John Doe');
      },
    );
  }
}
