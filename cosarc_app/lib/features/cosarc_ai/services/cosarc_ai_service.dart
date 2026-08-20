import '../models/chat_message.dart';

abstract class CosarcAiService {
  Future<ChatMessage> sendMessage({
    required String prompt,
    List<ChatMessage>? history,
  });

  Stream<String> streamMessage({
    required String prompt,
    List<ChatMessage>? history,
  });
}
