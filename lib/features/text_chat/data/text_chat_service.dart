import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

class TextChatService {
  ChatSession? _chatSession;

  void startChat({String? systemPrompt}) {
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction:
          systemPrompt != null ? Content.system(systemPrompt) : null,
    );
    _chatSession = model.startChat(history: []);
  }

  Future<String> sendMessage(String text) async {
    if (_chatSession == null) {
      throw Exception('Chat session not started');
    }

    try {
      final response =
          await _chatSession!.sendMessage(Content.text(text));
      return response.text ?? '';
    } catch (e) {
      debugPrint('TextChatService sendMessage error: $e');
      rethrow;
    }
  }

  void close() {
    _chatSession = null;
  }

  bool get isActive => _chatSession != null;
}
