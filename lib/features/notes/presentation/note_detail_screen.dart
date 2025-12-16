import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/theme_provider.dart';
import '../data/note_repository.dart';
import '../domain/note_model.dart';
import 'add_edit_note_screen.dart';

class NoteDetailScreen extends ConsumerWidget {
  final String noteId;
  final NoteModel initialNote;

  const NoteDetailScreen({super.key, required this.noteId, required this.initialNote});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteStreamProvider(noteId));
    final isDark = ref.watch(themeProvider);

    return noteAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text("Error: $e"))),
      data: (note) {

        // Color Logic
        Color bgColor = Color(note.colorValue);
        if (isDark && note.colorValue == 0xFFFFFFFF) {
          bgColor = const Color(0xFF1E1E1E);
        }
        final textColor = (isDark && note.colorValue == 0xFFFFFFFF) ? Colors.white : Colors.black87;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: textColor),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditNoteScreen(noteToEdit: note)));
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  _confirmDelete(context, ref);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 12),
                Text(
                  "Last edited: ${DateFormat('MMM d, h:mm a').format(note.lastEdited)}",
                  style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
                ),
                const SizedBox(height: 24),
                Text(
                  note.content,
                  style: TextStyle(fontSize: 18, height: 1.6, color: textColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Note?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ref.read(noteRepositoryProvider).deleteNote(noteId);
              Navigator.pop(ctx); // Close Dialog
              Navigator.pop(context); // Close Screen
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}