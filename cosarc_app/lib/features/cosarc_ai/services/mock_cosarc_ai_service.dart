import 'dart:async';
import 'dart:math';

import '../models/chat_message.dart';
import 'cosarc_ai_service.dart';

/// Mock implementation for UI development. Swap with a real LLM service later.
class MockCosarcAiService implements CosarcAiService {
  MockCosarcAiService({this.responseDelay = const Duration(milliseconds: 900)});

  final Duration responseDelay;
  final _random = Random();

  static const _responses = [
    'For muscle gain, prioritize compound lifts 3–4× weekly with progressive overload. Aim for 1.6–2.2 g protein per kg body weight.',
    'Sleep is your secret weapon. 7–9 hours supports recovery, hormone balance, and consistent training performance.',
    'Hydration matters: roughly 35 ml per kg daily, more on training days. Pair water intake with your daily contract.',
    'Consistency beats intensity. A moderate program you follow beats a perfect one you skip.',
    'Track protein across meals — breakfast often sets the tone. Greek yogurt, eggs, or dal are strong starts.',
  ];

  @override
  Future<ChatMessage> sendMessage({
    required String prompt,
    List<ChatMessage>? history,
  }) async {
    await Future.delayed(responseDelay);
    final text = _pickResponse(prompt);
    return ChatMessage(
      id: _id(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  @override
  Stream<String> streamMessage({
    required String prompt,
    List<ChatMessage>? history,
  }) async* {
    final text = _pickResponse(prompt);
    final words = text.split(' ');
    for (var i = 0; i < words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 45));
      yield i == 0 ? words[i] : ' ${words[i]}';
    }
  }

  String _pickResponse(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('protein')) {
      return _responses[4];
    }
    if (lower.contains('sleep')) {
      return _responses[1];
    }
    if (lower.contains('muscle') || lower.contains('gain')) {
      return _responses[0];
    }
    return _responses[_random.nextInt(_responses.length)];
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();
}
