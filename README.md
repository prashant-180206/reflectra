# reflectra

Personal journaling app with AI-assisted daily check-ins and structured diary generation.

**Features**
- **AI Daily Chat**: Conversational daily check-in powered by an Ollama-backed service. The chat can produce a structured Markdown diary entry from the conversation.
- **Persona Builder**: Onboarding flow that extracts the user's preferences and stores a `Persona` used to personalize responses.
- **Custom Instructions**: User-editable instructions (saved in Isar) that are appended to AI prompts for the daily chat.
- **Local storage**: Diary entries and persona data are persisted locally using Isar.

**Quick Links**
- `Daily chat wrapper`: [lib/core/AI/wrappers/daily_chat_ai.dart](lib/core/AI/wrappers/daily_chat_ai.dart)
- `Persona wrapper`: [lib/core/AI/wrappers/persona_chat_ai.dart](lib/core/AI/wrappers/persona_chat_ai.dart)
- `Custom instructions model`: [lib/core/database/models/custom_instruction.dart](lib/core/database/models/custom_instruction.dart)
- `Profile screen (editor)`: [lib/features/profile/presentation/screens/profile_screen.dart](lib/features/profile/presentation/screens/profile_screen.dart)
- `Database setup`: [lib/core/database/database.dart](lib/core/database/database.dart)

**Development Setup**

- Prerequisites: Flutter >= 3.7, Dart SDK compatible with project (see `pubspec.yaml`).
- Install packages:

```bash
flutter pub get
```

- Generate code (Isar and other builders):

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Running the app**

- Run on a connected device or emulator:

```bash
flutter run
```

**Database**
- Uses Isar via `isar_plus` and `isar_plus_flutter_libs`.
- Schemas are registered in `lib/core/database/database.dart`. If you add a new model, create the Dart model (with `part '<name>.g.dart';`) and run the code generator.
- If you hit `IsarError: Operation not supported` when writing, ensure you use the supported write API (`isar.write(...)`) rather than `writeAsync` in this build.

**AI / Ollama integration**
- API client logic lives in `lib/core/AI/ai.dart` and wrapper instructions in `lib/core/AI/wrappers/`.
- The app expects a BYOK-type API key stored via `flutter_secure_storage` (see `lib/core/security/apikeystore.dart`). Set your key before initializing the AI client.

**Custom Instructions**
- Users can edit a multiline “custom instructions” block from the Profile screen; it is saved to Isar and appended to the daily chat prompt. See:
	- [lib/features/profile/presentation/screens/profile_screen.dart](lib/features/profile/presentation/screens/profile_screen.dart)
	- [lib/core/database/crud/custom_instruction_db.dart](lib/core/database/crud/custom_instruction_db.dart)

**Troubleshooting / Notes**
- Code generation: the repo uses `build_runner`. If builders report mismatched analyzer versions, consider running the generator with `--delete-conflicting-outputs` and check `pubspec.yaml` for compatible versions.
- Streaming UI: `flutter_gen_ai_chat_ui` uses a streaming controller; make sure to call `controller.setStreamingMessage(null)` after finishing a streamed AI response to avoid re-animation issues.

**Contributing**
- Follow the existing project conventions. Run the code generator after adding or changing annotated models.

**Useful commands**

```bash
# get dependencies
flutter pub get

# run codegen
flutter pub run build_runner build --delete-conflicting-outputs

# run on device
flutter run
```