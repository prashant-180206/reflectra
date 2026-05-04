import 'package:flutter/material.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pattern_box/pattern_box.dart';
import 'package:reflectra/core/AI/wrappers/persona_chat_ai.dart';
import 'package:reflectra/core/singleton.dart';
import 'package:reflectra/features/profile/data/dbutils.dart';

class PersonaMakingChatScreen extends HookConsumerWidget {
  const PersonaMakingChatScreen({super.key, this.dayKey});

  final int? dayKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          if (!context.mounted) return;

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
      if (loading.value) return;

      controller.setStreamingMessage(null);

      controller.addMessage(
        ChatMessage(
          text: message.text,
          user: currentUser,
          createdAt: DateTime.now(),
        ),
      );

      loading.value = true;

      try {
        final response = await ollama.chat(message.text);

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
      } finally {
        loading.value = false;
      }
    }

    Future<void> finishAndSave() async {
      if (loading.value) return;

      loading.value = true;

      try {
        final personaText = await ollama.finishChat(null);

        if (!context.mounted) return;

        if (personaText.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No persona content was generated.')),
          );
          return;
        }

        await savePersonaEntry(personaText);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Persona saved successfully.')),
        );
      } finally {
        loading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Persona Builder'),
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
      body: PatternBoxWidget(
        pattern: DottedWavePainter(),
        backgroundGradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.05),
            colorScheme.primary.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: AiChatWidget(
              welcomeMessageConfig: WelcomeMessageConfig(
                title: "Let’s build your persona together",
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
                ),
              ),
              inputOptions: InputOptions(
                sendButtonColor: colorScheme.primary,
                cursorColor: colorScheme.primary,
                margin: EdgeInsets.fromLTRB(10, 4, 10, 4),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                sendOnEnter: true,
                decoration: InputDecoration.collapsed(
                  hintText: 'Explore Yourself ...',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
