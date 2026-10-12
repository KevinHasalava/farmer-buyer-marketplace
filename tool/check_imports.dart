import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  int totalFiles = 0;
  int importsAppSettings = 0;

  for (final file in files) {
    totalFiles++;
    final content = file.readAsStringSync();
    if (content.contains('app_settings.dart') || content.contains('auto_translator.dart')) {
      importsAppSettings++;
    }
  }

  print('Total dart files: $totalFiles');
  print('Files importing app_settings or auto_translator: $importsAppSettings');
}
