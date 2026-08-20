import '../models/chat_message.dart';
import '../models/chat_session.dart';

abstract class ChatRepository {
  Future<List<ChatSession>> listSessions();
  Future<ChatSession> createSession({String? title});
  Future<ChatSession> appendMessage({
    required String sessionId,
    required ChatMessage message,
  });
  Future<void> deleteSession(String sessionId);
}
