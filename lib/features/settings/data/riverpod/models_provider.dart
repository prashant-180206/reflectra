import 'package:reflectra/core/AI/ai.dart';
import 'package:reflectra/core/security/apikeystore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'models_provider.g.dart';

@Riverpod(keepAlive: true)
class AiModels extends _$AiModels {
  @override
  FutureOr<List<String>> build() async {
    state = AsyncError('API key Not Set', StackTrace.current);
    final haskey = await Apikeystore.hasKey();
    if (!haskey) {
      throw Exception('API key Not Set');
    }
    return OllamaBaseService.listModels();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final haskey = await Apikeystore.hasKey();
      if (!haskey) {
        throw Exception('API key Not Set');
      }
      return OllamaBaseService.listModels();
    });
  }
}
