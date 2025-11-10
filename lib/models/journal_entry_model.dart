import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String id;
  final String content;
  final Timestamp timestamp;

  JournalEntry({required this.id, required this.content, required this.timestamp});

  factory JournalEntry.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return JournalEntry(
      id: doc.id,
      content: data['content'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}