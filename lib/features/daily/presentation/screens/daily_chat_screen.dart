import 'package:flutter/material.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pattern_box/pattern_box.dart';
import 'package:reflectra/core/AI/wrappers/daily_chat_ai.dart';
import 'package:reflectra/core/routes/app_routes.dart';
import 'package:reflectra/core/singleton.dart';
import 'package:reflectra/features/daily/data/dbconnect.dart';

class DailyChatScreen extends HookConsumerWidget {
  const DailyChatScreen({super.key, this.dayKey});
  final int? dayKey;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Define Theme Variable for easy access
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final currentUser = ChatUser(id: 'user1', name: 'You');
    final aiUser = ChatUser(id: 'ai', name: 'AI');
    final controller = useRef(ChatMessagesController()).value;
    final loading = useState(false);
    final ollama = useMemoized(() => DailyChatAi());

    useEffect(() {
      Future<void> initialize() async {
        try {
          await ollama.init();
        } catch (e) {
          logger.e('Failed to initialize AI client: $e');
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to initialize AI. Check BYOK settings.'),
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
      if (loading.value) return;

      loading.value = true;
      controller.setStreamingMessage(null);
      try {
        String response;

        if (message.text.trim().isEmpty) {
          response = await ollama.continueChat();
        } else {
          controller.addMessage(
            ChatMessage(
              text: message.text,
              user: currentUser,
              createdAt: DateTime.now(),
            ),
          );
          response = await ollama.chat(message.text);
        }

        final responseId = 'ai_${DateTime.now().microsecondsSinceEpoch}';
        controller.addMessage(
          ChatMessage(
            text: response,
            user: aiUser,
            createdAt: DateTime.now(),
            customProperties: {'id': responseId},
          ),
        );
        controller.setStreamingMessage(responseId);
      } catch (e) {
        logger.e("Chat error: $e");
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 20,
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                AiSettingsRoute().push(context);
              },
            ),
            content: Text(
              'Configure Your API key in settings to use AI features.',
            ),
          ),
        );
      } finally {
        loading.value = false;
      }
    }

    Future<void> finishAndSave() async {
      if (loading.value) return;
      loading.value = true;

      try {
        final diaryText = await ollama.finishChat(null);

        if (!context.mounted) return;
        if (diaryText.trim().isEmpty) return;

        final savedId = await saveDiaryEntry(diaryText);
        if (!context.mounted) return;

        await EntryEditorRoute(entryId: savedId).push(context);
      } finally {
        loading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Daily Chat'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: finishAndSave,
              icon: const Icon(Icons.check),
              tooltip: "Finish",
              color: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: PatternBoxWidget(
          pattern: DottedWavePainter(),
          backgroundGradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.05),
              colorScheme.primary.withValues(alpha: 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

          // child: PatternBoxWidget(pattern: DottedWavePainter()),
          child: AiChatWidget(
            padding: const EdgeInsets.all(0),
            welcomeMessageConfig: WelcomeMessageConfig(
              title: "Let's talk about your day",
              containerDecoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              titleStyle: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            enableMarkdownStreaming: true,
            loadingConfig: LoadingConfig(
              isLoading: loading.value,
              typingIndicatorColor: colorScheme.primary,
            ),
            currentUser: currentUser,
            aiUser: aiUser,
            controller: controller,
            onSendMessage: handleSendMessage,

            messageOptions: MessageOptions(
              showUserName: false,
              showTime: false,
              aiTextColor: colorScheme.onSurfaceVariant,
              userTextColor: colorScheme.onPrimary,
              bubbleStyle: BubbleStyle(
                userBubbleColor: colorScheme.primary,
                aiBubbleColor: colorScheme.surfaceContainerHighest,
                aiNameColor: colorScheme.onSurfaceVariant,
                userNameColor: colorScheme.onPrimary,
                // userTextStyle: TextStyle(color: colorScheme.onPrimary),
              ),
            ),

            inputOptions: InputOptions(
              sendButtonColor: colorScheme.primary,
              cursorColor: colorScheme.primary,
              margin: EdgeInsets.fromLTRB(10, 4, 10, 4),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              sendOnEnter: true,
              decoration: InputDecoration.collapsed(
                hintText: 'Reflect on your day...',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
