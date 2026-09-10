import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save a translation to history
  Future<void> saveTranslation(String romanizedText, String khmerText) async {
    final user = _auth.currentUser;
    // Only save if the user is logged in
    if (user == null) return; 

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .add({
      'romanizedText': romanizedText,
      'khmerText': khmerText,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get stream of history items
  Stream<QuerySnapshot> getHistory() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  
  // Format the Firestore timestamp into a readable string like "Today" or "Oct 24"
  static String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0 && now.day == date.day) {
      return 'Today';
    } else if (difference == 1 || (difference == 0 && now.day != date.day)) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  // delete history item
  Future<void> deleteHistoryItem(String docId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .doc(docId)
        .delete();
  }

  // --- LIBRARY METHODS ---
  
  // Add a word to the user's personal library
  Future<void> addLibraryWord(String romanized, String khmer, List<String> aliases) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('library')
        .add({
      'romanized': romanized,
      'khmer': khmer,
      'aliases': aliases,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Update a word in the user's personal library
  Future<void> updateLibraryWord(String docId, String romanized, String khmer) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('library')
        .doc(docId)
        .update({
      'romanized': romanized,
      'khmer': khmer,
    });
  }

  // Delete a word from the library
  Future<void> deleteLibraryWord(String docId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('library')
        .doc(docId)
        .delete();
  }

  // Get stream of library words
  Stream<QuerySnapshot> getLibrary() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('library')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
