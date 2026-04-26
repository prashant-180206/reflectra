import 'package:flutter/material.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindlog/core/AI/wrappers/daily_chat_ai.dart';
import 'package:mindlog/core/database/database.dart';
import 'package:mindlog/core/database/models/diary_entry.dart';
import 'package:mindlog/core/routes/app_routes.dart';
import 'package:mindlog/core/singleton.dart';

class DailyChatScreen extends HookConsumerWidget {
  const DailyChatScreen({super.key, this.dayKey});

  final int? dayKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ChatUser(id: 'user1', name: 'You');
    final aiUser = ChatUser(id: 'ai', name: 'AI');
    final controller = useRef(ChatMessagesController()).value;
    final loading = useState(false);
    final ollama = useMemoized(() => DailyChatAi());

    final resolvedDayKey = dayKey ?? Database.dayKeyFromDate(DateTime.now());

    String extractTitle(String markdown) {
      final lines = markdown.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('#')) {
          return trimmed.replaceFirst(RegExp(r'^#+\s*'), '').trim();
        }
      }
      final firstLine = lines.isEmpty ? 'Daily Entry' : lines.first.trim();
      if (firstLine.isEmpty) {
        return 'Daily Entry';
      }
      return firstLine.substring(
        0,
        firstLine.length > 48 ? 48 : firstLine.length,
      );
    }

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

      // Ensure older AI responses are finalized so they do not restart streaming.
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

      if (!context.mounted) {
        return;
      }

      if (diaryText.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No diary content was generated.')),
        );
        return;
      }

      final entry = DiaryEntry(
        dayKey: resolvedDayKey,
        createdAt: DateTime.now(),
        title: extractTitle(diaryText),
        content: diaryText,
        source: 'ai',
      );
      final savedId = await Database.saveEntry(entry);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI entry saved. Opening editor...')),
      );
      await EntryEditorRoute(
        entryId: savedId,
        dayKey: resolvedDayKey,
      ).push(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Daily Chat'),
        actions: [
          TextButton(onPressed: finishAndSave, child: const Text('Finish')),
        ],
      ),
      body: AiChatWidget(
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
