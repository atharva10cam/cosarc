import '../models/chat_message.dart';
import '../models/chat_session.dart';
import 'chat_repository.dart';

class InMemoryChatRepository implements ChatRepository {
  final Map<String, ChatSession> _sessions = {};

  @override
  Future<List<ChatSession>> listSessions() async {
    final sessions = _sessions.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sessions;
  }

  @override
  Future<ChatSession> createSession({String? title}) async {
    final now = DateTime.now();
    final session = ChatSession(
      id: now.microsecondsSinceEpoch.toString(),
      title: title ?? 'New chat',
      messages: const [],
      createdAt: now,
      updatedAt: now,
    );
    _sessions[session.id] = session;
    return session;
  }

  @override
  Future<ChatSession> appendMessage({
    required String sessionId,
    required ChatMessage message,
  }) async {
    final existing = _sessions[sessionId];
    if (existing == null) {
      throw StateError('Session not found');
    }
    final updated = existing.copyWith(
      messages: [...existing.messages, message],
      updatedAt: DateTime.now(),
      title: existing.messages.isEmpty && message.isUser
          ? _titleFromPrompt(message.text)
          : existing.title,
    );
    _sessions[sessionId] = updated;
    return updated;
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    _sessions.remove(sessionId);
  }

  String _titleFromPrompt(String prompt) {
    final trimmed = prompt.trim();
    if (trimmed.length <= 32) return trimmed;
    return '${trimmed.substring(0, 29)}…';
  }
}
