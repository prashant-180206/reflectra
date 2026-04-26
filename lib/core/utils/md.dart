class MdUtils {
  static String extractTitle(String markdown) {
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
}
