import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:reflectra/core/singleton.dart';
import 'package:reflectra/features/profile/utils/functions.dart';

class UpdatePersonaButton extends HookWidget {
  const UpdatePersonaButton({super.key, this.onCompleted});

  final Future<void> Function(bool success)? onCompleted;

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);

    Future<void> handlePress() async {
      if (isLoading.value) return;

      isLoading.value = true;

      bool success = false;

      try {
        success = await setPersonaFromEntries();
      } catch (e) {
        logger.e(e);
      }

      if (context.mounted && onCompleted != null) {
        await onCompleted!(success);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Persona updated from entries!'
                  : 'Failed to update persona from entries. , Make sure to select AI model and add API key',
            ),
          ),
        );
      }

      if (context.mounted) {
        isLoading.value = false;
      }
    }

    return ElevatedButton.icon(
      onPressed: isLoading.value ? null : handlePress,
      icon: isLoading.value
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.auto_fix_high),
      label: Text(isLoading.value ? 'Updating...' : 'Update from Entries'),
    );
  }
}
