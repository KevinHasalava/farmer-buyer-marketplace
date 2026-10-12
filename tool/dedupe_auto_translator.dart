import 'dart:io';

void main() {
  final file = File('lib/core/localization/auto_translator.dart');
  final lines = file.readAsLinesSync();

  final seen = <String>{};
  final output = <String>[];

  final keyRegex = RegExp(r'''^\s*['"]([^'"]+)['"]\s*:''');

  bool inUiPhrases = false;

  for (final line in lines) {
    if (line.contains('_uiPhrases = {')) {
      inUiPhrases = true;
      output.add(line);
      continue;
    }
    if (inUiPhrases && line.trim() == '};') {
      inUiPhrases = false;
      output.add(line);
      continue;
    }

    if (inUiPhrases) {
      final m = keyRegex.firstMatch(line);
      if (m != null) {
        final key = m.group(1)!;
        if (seen.contains(key)) {
          // Skip duplicate key
          continue;
        }
        seen.add(key);
      }
    }

    output.add(line);
  }

  file.writeAsStringSync(output.join('\n'));
  print('Successfully deduplicated auto_translator.dart. Unique keys: ${seen.length}');
}
