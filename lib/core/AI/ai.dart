import 'package:reflectra/core/security/apikeystore.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:reflectra/core/security/model_name_store.dart';
// import 'package:reflectra/core/singleton.dart';

class OllamaBaseService {
  final String instructions;
  final messagelist = <ChatMessage>[]; // for conversation only
  static OllamaClient? ai;
  static String modelName = 'gpt-oss:120b';

  OllamaBaseService({this.instructions = ''}) {
    if (instructions.isNotEmpty) {
      messagelist.add(ChatMessage.system(instructions));
    }
  }

  Future<void> addInstructions(String instructions) async {
    messagelist.insert(0, ChatMessage.system(instructions));
  }

  Future<void> init() async {
    final apiKey = await Apikeystore.getKey();
    final model = await ModelNameStore.getModelName();
    if (model == null) {
      ModelNameStore.setModelName('gpt-oss:120b');
    }
    modelName = model ?? 'gpt-oss:120b';

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
      request: ChatRequest(model: modelName, messages: messagelist),
    );

    final content = response.message?.content ?? '';

    messagelist.add(ChatMessage.assistant(content));

    return content;
  }

  Future<String> continueChat() async {
    if (ai == null) throw Exception('AI not initialized');
    final response = await ai!.chat.create(
      request: ChatRequest(model: modelName, messages: messagelist),
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
      request: ChatRequest(model: modelName, messages: diaryMessages),
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
    if (instructions.isNotEmpty) {
      messagelist.add(ChatMessage.system(instructions));
    }
  }

  void close() {
    ai?.close();
  }

  static Future<List<String>> listModels() async {
    final temp = OllamaBaseService();
    await temp.init();
    if (ai == null) throw Exception('AI not initialized');
    final response = await ai!.models.list();
    final modelNames =response.models?.map((m) => m.name ?? '').toList() ?? [];
    temp.close();
    return modelNames;
  }
}
