import 'package:reflectra/core/AI/ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'models_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<String>> aimodels(Ref ref) async {
  return OllamaBaseService.listModels();
}
