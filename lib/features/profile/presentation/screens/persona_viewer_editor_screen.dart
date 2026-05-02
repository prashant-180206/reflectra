import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reflectra/core/database/crud/persona_db.dart';
import 'package:reflectra/core/database/models/persona.dart';
import 'package:reflectra/core/singleton.dart';

class PersonaViewerEditorScreen extends HookConsumerWidget {
  const PersonaViewerEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(true);
    final isSaving = useState(false);
    final persona = useState<Persona?>(null);

    // Controllers
    final preferredNameController = useTextEditingController();
    final ageRangeController = useTextEditingController();
    final occupationController = useTextEditingController();
    final regionController = useTextEditingController();

    final traitsController = useTextEditingController();
    final thinkingStyleController = useTextEditingController();
    final energyPatternController = useTextEditingController();

    final hobbiesController = useTextEditingController();
    final goalsController = useTextEditingController();

    final additionalContextController = useTextEditingController();

    void populate(Persona? p) {
      preferredNameController.text = p?.identity?.preferredName ?? '';
      ageRangeController.text = p?.identity?.ageRange ?? '';
      occupationController.text = p?.identity?.occupationOrField ?? '';
      regionController.text = p?.identity?.region ?? '';

      traitsController.text = _join(p?.personality?.traits);
      thinkingStyleController.text = p?.personality?.thinkingStyle ?? '';
      energyPatternController.text = p?.personality?.energyPattern ?? '';

      hobbiesController.text = _join(p?.interests?.hobbies);
      goalsController.text = _join(p?.goals?.shortTerm);

      additionalContextController.text = p?.additionalContext ?? '';
    }

    useEffect(() {
      Future(() async {
        try {
          final p = await PersonaDb.getPersona();
          persona.value = p;
          populate(p);
        } catch (e) {
          logger.e(e);
        } finally {
          isLoading.value = false;
        }
      });
      return null;
    }, []);

    Future<void> save() async {
      if (isSaving.value) return;

      isSaving.value = true;

      try {
        final updated = Persona(
          id: 0,
          identity: Identity(
            preferredName: preferredNameController.text,
            ageRange: ageRangeController.text,
            occupationOrField: occupationController.text,
            region: regionController.text,
          ),
          personality: Personality(
            traits: _split(traitsController.text),
            thinkingStyle: thinkingStyleController.text,
            energyPattern: energyPatternController.text,
          ),
          interests: Interests(hobbies: _split(hobbiesController.text)),
          goals: Goals(shortTerm: _split(goalsController.text)),
          additionalContext: additionalContextController.text,
        );

        await PersonaDb.savePersona(updated);
        persona.value = updated;

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Saved')));
        }
      } catch (e) {
        logger.e(e);
      } finally {
        isSaving.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Persona"),
        actions: [
          TextButton(
            onPressed: isLoading.value ? null : save,
            child: isSaving.value
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Save"),
          ),
        ],
      ),
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _Header(persona: persona.value),

                const SizedBox(height: 24),

                _Section(
                  title: "Identity",
                  children: [
                    NotebookField(
                      controller: preferredNameController,
                      hint: "Your name",
                    ),
                    NotebookField(
                      controller: ageRangeController,
                      hint: "Age range",
                    ),
                    NotebookField(
                      controller: occupationController,
                      hint: "What do you do",
                    ),
                    NotebookField(
                      controller: regionController,
                      hint: "Where are you from",
                    ),
                  ],
                ),

                _Section(
                  title: "Personality",
                  children: [
                    NotebookField(
                      controller: traitsController,
                      hint: "Traits (comma separated)",
                    ),
                    NotebookField(
                      controller: thinkingStyleController,
                      hint: "How you think",
                    ),
                    NotebookField(
                      controller: energyPatternController,
                      hint: "Energy pattern",
                    ),
                  ],
                ),

                _Section(
                  title: "Life",
                  children: [
                    NotebookField(
                      controller: hobbiesController,
                      hint: "Hobbies",
                    ),
                    NotebookField(controller: goalsController, hint: "Goals"),
                  ],
                ),

                _Section(
                  title: "Notes",
                  children: [
                    NotebookField(
                      controller: additionalContextController,
                      hint: "Write freely about yourself...",
                      maxLines: 6,
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  static List<String>? _split(String raw) {
    final v = raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return v.isEmpty ? null : v;
  }

  static String _join(List<String>? v) {
    if (v == null || v.isEmpty) return '';
    return v.join(', ');
  }
}

/* ================= UI COMPONENTS ================= */

class NotebookField extends StatelessWidget {
  const NotebookField({
    super.key,
    required this.controller,
    this.hint,
    this.maxLines = 2,
  });

  final TextEditingController controller;
  final String? hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NotebookLinesPainter(context),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
        ),
        style: const TextStyle(height: 1.6),
      ),
    );
  }
}

class _NotebookLinesPainter extends CustomPainter {
  final BuildContext context;

  _NotebookLinesPainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Theme.of(context).dividerColor.withValues(alpha: 0.4)
      ..strokeWidth = 1;

    const lineHeight = 28.0;

    for (double y = lineHeight; y < size.height; y += lineHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 1.5,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.persona});

  final Persona? persona;

  @override
  Widget build(BuildContext context) {
    final name = persona?.identity?.preferredName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name != null && name.isNotEmpty ? name : "Your Persona",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          "Write about yourself like a notebook entry.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
