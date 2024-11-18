// lib/models/diary.dart
class Diary {
  final String id;
  final String content;
  final String imagePath;
  final DateTime date;

  Diary({
    required this.id,
    required this.content,
    required this.imagePath,
    required this.date,
  });
}