import 'package:mindlog/core/security/apikeystore.dart';
import 'package:ollama_dart/ollama_dart.dart';
// import 'package:mindlog/core/singleton.dart';

class OllamaBaseService {
  final String instructions;
  final messagelist = <ChatMessage>[]; // for conversation only
  OllamaClient? ai;

  OllamaBaseService(this.instructions) {
    messagelist.add(ChatMessage.system(instructions));
  }

  Future<void> init() async {
    final apiKey = await Apikeystore.getKey();

    ai = OllamaClient(
      config: OllamaConfig(
        baseUrl: 'https://ollama.com', // or your backend
        defaultHeaders: {'Authorization': 'Bearer $apiKey'},
      ),
    );
  }

  // 🔹 NORMAL CHAT (Conversation Agent)
  Future<String> chat(String prompt) async {
    if (ai == null) throw Exception('AI not initialized');

    messagelist.add(ChatMessage.user(prompt));

    final response = await ai!.chat.create(
      request: ChatRequest(
        model: 'gpt-oss:120b-cloud',
        messages: messagelist,
      ),
    );

    final content = response.message?.content ?? '';

    messagelist.add(ChatMessage.assistant(content));

    return content;
  }

  // 🔹 DIARY GENERATION (Separate Agent, SAME CLIENT)
  Future<String> finishChat(String? diaryInstructions) async {
    if (ai == null) throw Exception('AI not initialized');

    // ⚠️ IMPORTANT: Create NEW message list
    final diaryMessages = [
      ChatMessage.system(diaryInstructions ?? ''),
      ChatMessage.user(_formatConversation()),
    ];

    final response = await ai!.chat.create(
      request: ChatRequest(
        model: 'gpt-oss:120b-cloud',
        messages: diaryMessages,
      ),
    );

    return response.message?.content ?? '';
  }

  // 🔹 Helper: convert conversation → string
  String _formatConversation() {
    return messagelist
        .where((m) => m.role != MessageRole.system)
        .map((m) => "${m.role.name}: ${m.content}")
        .join("\n");
  }

  void clearchat() {
    messagelist.clear();
    messagelist.add(ChatMessage.system(instructions));
  }

  void close() {
    ai?.close();
  }
}