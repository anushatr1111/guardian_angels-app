import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_safe_app/models/journal_entry_model.dart';

class JournalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper to get the user's journal subcollection
  CollectionReference? _getJournalCollection() {
    final String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return null;
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('journal_entries');
  }

  // Create (Step 24.3)
  Future<void> addJournalEntry(String content) async {
    final collectionRef = _getJournalCollection();
    if (collectionRef != null) {
      await collectionRef.add({
        'content': content,
        'timestamp': Timestamp.now(),
      });
    }
  }

  // Read (Step 24.3)
  Stream<List<JournalEntry>> getJournalEntriesStream() {
    final collectionRef = _getJournalCollection();
    if (collectionRef == null) return Stream.value([]);
    return collectionRef
        .orderBy('timestamp', descending: true) // Show newest first
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JournalEntry.fromFirestore(doc))
            .toList());
  }

  // Delete (Step 24.3)
  Future<void> deleteJournalEntry(String entryId) async {
     final collectionRef = _getJournalCollection();
     if (collectionRef != null) {
       await collectionRef.doc(entryId).delete();
     }
  }
}