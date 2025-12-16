import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/note_model.dart';

class NoteRepository {
  final FirebaseFirestore _firestore;
  final String userId;
  NoteRepository(this._firestore, this.userId);

  // GET LIST (Sorted by last edited)
  Stream<List<NoteModel>> getNotes() {
    return _firestore.collection('users').doc(userId).collection('notes')
        .orderBy('lastEdited', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => NoteModel.fromMap(doc.data())).toList());
  }

  // GET SINGLE
  Stream<NoteModel> getNote(String id) {
    return _firestore.collection('users').doc(userId).collection('notes').doc(id)
        .snapshots()
        .map((doc) {
      if (!doc.exists) throw Exception("Note deleted");
      return NoteModel.fromMap(doc.data()!);
    });
  }

  // CREATE
  Future<void> addNote(String title, String content, int colorValue) async {
    final doc = _firestore.collection('users').doc(userId).collection('notes').doc();
    final now = DateTime.now();
    await doc.set(NoteModel(
        id: doc.id,
        title: title,
        content: content,
        date: now,
        lastEdited: now,
        colorValue: colorValue
    ).toMap());
  }

  // UPDATE
  Future<void> updateNote(NoteModel note) async {
    // Only update changed fields + lastEdited
    await _firestore.collection('users').doc(userId).collection('notes').doc(note.id).update({
      'title': note.title,
      'content': note.content,
      'colorValue': note.colorValue,
      'lastEdited': Timestamp.fromDate(DateTime.now()),
    });
  }

  // DELETE
  Future<void> deleteNote(String id) async {
    await _firestore.collection('users').doc(userId).collection('notes').doc(id).delete();
  }
}

final noteRepositoryProvider = Provider((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) throw Exception("No User");
  return NoteRepository(FirebaseFirestore.instance, user.uid);
});

final noteListProvider = StreamProvider((ref) => ref.watch(noteRepositoryProvider).getNotes());

final noteStreamProvider = StreamProvider.family<NoteModel, String>((ref, id) {
  return ref.watch(noteRepositoryProvider).getNote(id);
});