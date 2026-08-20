import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../repositories/chat_repository.dart';
import '../services/cosarc_ai_service.dart';
import '../services/mock_cosarc_ai_service.dart';
import 'in_memory_chat_repository.dart';

/// Lightweight provider for Cosarc AI chat state.
/// Replace [MockCosarcAiService] with a production LLM service when ready.
class CosarcAiProvider extends ChangeNotifier {
  CosarcAiProvider({
    CosarcAiService? service,
    ChatRepository? repository,
  })  : _service = service ?? MockCosarcAiService(),
        _repository = repository ?? InMemoryChatRepository();

  final CosarcAiService _service;
  final ChatRepository _repository;

  ChatSession? _session;
  bool _isSending = false;
  String? _streamingBuffer;

  ChatSession? get session => _session;
  List<ChatMessage> get messages => _session?.messages ?? const [];
  bool get isSending => _isSending;
  String? get streamingBuffer => _streamingBuffer;

  Future<void> initialize() async {
    if (_session != null) return;
    _session = await _repository.createSession(title: 'Cosarc AI');
    notifyListeners();
  }

  Future<void> send(String prompt) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty || _isSending) return;

    await initialize();
    final sessionId = _session!.id;

    final userMessage = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _session = await _repository.appendMessage(
      sessionId: sessionId,
      message: userMessage,
    );
    _isSending = true;
    _streamingBuffer = '';
    notifyListeners();

    try {
      final buffer = StringBuffer();
      await for (final chunk in _service.streamMessage(
        prompt: trimmed,
        history: _session!.messages,
      )) {
        buffer.write(chunk);
        _streamingBuffer = buffer.toString();
        notifyListeners();
      }

      final assistantMessage = ChatMessage(
        id: '${DateTime.now().microsecondsSinceEpoch}-ai',
        text: buffer.toString().trim().isEmpty
            ? (await _service.sendMessage(
                prompt: trimmed,
                history: _session!.messages,
              ))
                .text
            : buffer.toString(),
        isUser: false,
        timestamp: DateTime.now(),
      );

      _session = await _repository.appendMessage(
        sessionId: sessionId,
        message: assistantMessage,
      );
    } finally {
      _streamingBuffer = null;
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> clearChat() async {
    if (_session == null) return;
    await _repository.deleteSession(_session!.id);
    _session = await _repository.createSession(title: 'Cosarc AI');
    notifyListeners();
  }
}
