import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../repositories/chat_repository.dart';

class InMemoryChatRepository implements ChatRepository {
  final List<ChatSession> _sessions = [];

  @override
  Future<List<ChatSession>> listSessions() async => _sessions;

  @override
  Future<ChatSession> createSession({String? title}) async {
    final session = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title ?? 'New Chat',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: const [],
    );
    _sessions.add(session);
    return session;
  }

  @override
  Future<ChatSession> appendMessage(
      {required String sessionId, required ChatMessage message}) async {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index >= 0) {
      final session = _sessions[index];
      _sessions[index] =
          session.copyWith(messages: [...session.messages, message]);
      return _sessions[index];
    }
    throw Exception('Session not found');
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
  }
}
