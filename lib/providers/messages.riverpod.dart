import 'package:aw/screens/message.screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageNotifier extends StateNotifier<List<MessageBubble>> {
  MessageNotifier() : super([]);

  void addMessage(MessageBubble message) {
    state = [...state, message];
  }

  void load(List<MessageBubble> messages) {
    state = messages;
  }
}

final messageProvider =
    StateNotifierProvider<MessageNotifier, List<MessageBubble>>((ref) {
  return MessageNotifier();
});
