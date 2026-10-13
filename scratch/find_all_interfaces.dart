import 'dart:io';

void main() {
  final file = File(r'C:\Users\USER\.gemini\antigravity-ide\brain\2ca62779-e37c-41a1-94f6-923129a0da3f\scratch\extracted_doc.txt');
  final lines = file.readAsLinesSync();
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.startsWith('6.') || line.contains('IT238') || line.contains('Interface Name')) {
      print('Line $i: $line');
    }
  }
}
