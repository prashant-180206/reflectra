import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reflectra/core/database/crud/persona_db.dart';
import 'package:reflectra/core/database/models/persona.dart';
import 'package:reflectra/core/singleton.dart';
import 'package:reflectra/features/profile/presentation/widgets/update_persona_button.dart';

class PersonaViewerEditorScreen extends HookConsumerWidget {
  const PersonaViewerEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(true);
    final isSaving = useState(false);
    final persona = useState<Persona?>(null);

    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());

    Future<void> loadPersona() async {
      try {
        final p = await PersonaDb.getPersona();
        persona.value = p;

        // populate form
        formKey.currentState?.patchValue({
          'preferredName': p?.identity?.preferredName,
          'ageRange': p?.identity?.ageRange,
          'occupation': p?.identity?.occupationOrField,
          'region': p?.identity?.region,

          'traits': _join(p?.personality?.traits),
          'thinkingStyle': p?.personality?.thinkingStyle,
          'energyPattern': p?.personality?.energyPattern,

          'hobbies': _join(p?.interests?.hobbies),
          'goals': _join(p?.goals?.shortTerm),

          'additionalContext': p?.additionalContext,
        });
      } catch (e) {
        logger.e(e);
      } finally {
        isLoading.value = false;
      }
    }

    useEffect(() {
      loadPersona();
      return null;
    }, []);

    Future<void> save() async {
      if (isSaving.value) return;

      final form = formKey.currentState!;
      form.save();

      final data = form.value;

      isSaving.value = true;

      try {
        final updated = Persona(
          id: persona.value?.id ?? 0,
          identity: Identity(
            preferredName: data['preferredName'],
            ageRange: data['ageRange'],
            occupationOrField: data['occupation'],
            region: data['region'],
          ),
          personality: Personality(
            traits: _split(data['traits']),
            thinkingStyle: data['thinkingStyle'],
            energyPattern: data['energyPattern'],
          ),
          interests: Interests(hobbies: _split(data['hobbies'])),
          goals: Goals(shortTerm: _split(data['goals'])),
          additionalContext: data['additionalContext'],
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

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Your Persona"),
          actions: [
            IconButton(
              onPressed: isLoading.value || isSaving.value ? null : save,
              icon: isSaving.value
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              tooltip: "Save Persona",
            ),
          ],
        ),
        body: isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : FormBuilder(
                key: formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _Header(persona: persona.value),
      
                    const SizedBox(height: 12),
      
                    /// 🔥 AI Button with refresh
                    UpdatePersonaButton(
                      onCompleted: (success) async {
                        if (success) {
                          await loadPersona(); // refresh UI
                        }
                      },
                    ),
      
                    const SizedBox(height: 24),
      
                    _Section(
                      title: "Identity",
                      children: [
                        _field("preferredName", "Your name"),
                        _field("ageRange", "Age range"),
                        _field("occupation", "What do you do"),
                        _field("region", "Where are you from"),
                      ],
                    ),
      
                    _Section(
                      title: "Personality",
                      children: [
                        _field("traits", "Traits (comma separated)"),
                        _field("thinkingStyle", "How you think"),
                        _field("energyPattern", "Energy pattern"),
                      ],
                    ),
      
                    _Section(
                      title: "Life",
                      children: [
                        _field("hobbies", "Hobbies"),
                        _field("goals", "Goals"),
                      ],
                    ),
      
                    _Section(
                      title: "Notes",
                      children: [
                        _field(
                          "additionalContext",
                          "Write freely about yourself...",
                          maxLines: 6,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// 🔧 Field builder
  Widget _field(String name, String hint, {int maxLines = 2}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FormBuilderTextField(
        name: name,
        maxLines: maxLines,
        decoration: InputDecoration.collapsed(hintText: hint),
      ),
    );
  }

  static List<String>? _split(String? raw) {
    if (raw == null) return null;
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration.collapsed(hintText: hint),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
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
