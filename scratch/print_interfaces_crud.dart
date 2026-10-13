import 'dart:io';

void main() {
  final file = File(r'C:\Users\USER\.gemini\antigravity-ide\brain\2ca62779-e37c-41a1-94f6-923129a0da3f\scratch\extracted_doc.txt');
  final lines = file.readAsLinesSync();
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.contains('Interface Name') || line.startsWith('6.2') || line.startsWith('6.3') || line.startsWith('6.4') || line.startsWith('6.5') || line.contains('CRUD Operations')) {
      // print line and next 3 lines
      final context = lines.sublist(i, (i + 4 < lines.length) ? i + 4 : lines.length).map((l) => l.trim()).join(' | ');
      print('Line $i: $context');
    }
  }
}
