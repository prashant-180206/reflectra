import 'package:flutter/material.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindlog/core/AI/wrappers/persona_chat_ai.dart';
import 'package:mindlog/core/routes/app_routes.dart';
import 'package:mindlog/core/singleton.dart';
import 'package:mindlog/features/daily/data/dbconnect.dart';

class PersonaMakingChatScreen extends HookConsumerWidget {
  const PersonaMakingChatScreen({super.key, this.dayKey});

  final int? dayKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ChatUser(id: 'user1', name: 'You');
    final aiUser = ChatUser(id: 'ai', name: 'AI');
    final controller = useRef(ChatMessagesController()).value;
    final loading = useState(false);
    final ollama = useMemoized(() => PersonaProfileAi());

    useEffect(() {
      Future<void> initialize() async {
        try {
          await ollama.init();
        } catch (e) {
          logger.e('Failed to initialize AI client: $e');
          if (!context.mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to initialize AI client. Check your API key in BYOK settings.',
              ),
            ),
          );
        }
      }
      initialize();
      return () {
        controller.dispose();
        ollama.close();
      };
    }, []);

    Future<void> handleSendMessage(ChatMessage message) async {
      if (loading.value) {
        return;
      }

      logger.d('Message sent: $message');

      controller.setStreamingMessage(null);

      controller.addMessage(
        ChatMessage(
          text: message.text,
          user: currentUser,
          createdAt: DateTime.now(),
        ),
      );

      loading.value = true;
      final response = await ollama.chat(message.text);
      loading.value = false;

      final responseId = 'ai_${DateTime.now().microsecondsSinceEpoch}';
      controller.setStreamingMessage(responseId);
      controller.addMessage(
        ChatMessage(
          text: response,
          user: aiUser,
          createdAt: DateTime.now(),
          customProperties: {'id': responseId},
        ),
      );
      // controller.setStreamingMessage(null);
    }

    Future<void> finishAndSave() async {
      if (loading.value) {
        return;
      }
      loading.value = true;
      final diaryText = await ollama.finishChat(null);
      logger.d('Diary generation complete: $diaryText');
      loading.value = false;

      if (!context.mounted) return;

      if (diaryText.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No diary content was generated.')),
        );
        return;
      }

      final savedId = await saveDiaryEntry(diaryText);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI entry saved. Opening editor...')),
      );
      await EntryEditorRoute(entryId: savedId).push(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Daily Chat'),
        actions: [
          TextButton(onPressed: finishAndSave, child: const Text('Finish')),
        ],
      ),
      body: AiChatWidget(
        welcomeMessageConfig: WelcomeMessageConfig(
          title: "Lets Talk about your day",
        ),
        enableMarkdownStreaming: true,
        quickReplyOptions: const QuickReplyOptions(),

        loadingConfig: LoadingConfig(isLoading: loading.value),
        padding: const EdgeInsets.all(16),
        currentUser: currentUser,
        aiUser: aiUser,
        controller: controller,
        onSendMessage: handleSendMessage,
        messageOptions: const MessageOptions(
          showUserName: false,
          showTime: false,
          padding: EdgeInsets.all(10),
        ),
        inputOptions: InputOptions(
          sendOnEnter: true,
          decoration: InputDecoration(
            hintText: 'Type your message...',

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
    );
  }
}
