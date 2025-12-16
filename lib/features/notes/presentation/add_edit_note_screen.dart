import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../data/note_repository.dart';
import '../domain/note_model.dart';

class AddEditNoteScreen extends ConsumerStatefulWidget {
  final NoteModel? noteToEdit;
  const AddEditNoteScreen({super.key, this.noteToEdit});

  @override
  ConsumerState<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends ConsumerState<AddEditNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int _selectedColor = 0xFFFFFFFF; // Default White
  bool _isLoading = false;

  // Available Note Colors
  final List<int> _colors = [
    0xFFFFFFFF, // White
    0xFFF28B82, // Red
    0xFFFBBC04, // Orange
    0xFFFFF475, // Yellow
    0xFFCCFF90, // Green
    0xFFA7FFEB, // Teal
    0xFFCBF0F8, // Blue
    0xFFAECBFA, // Dark Blue
    0xFFD7AEFB, // Purple
    0xFFE6C9A8, // Brown
  ];

  @override
  void initState() {
    super.initState();
    if (widget.noteToEdit != null) {
      _titleController.text = widget.noteToEdit!.title;
      _contentController.text = widget.noteToEdit!.content;
      _selectedColor = widget.noteToEdit!.colorValue;
    } else {
      // If adding new, adapt default color to theme (Dark Grey for Dark Mode, White for Light)
      // We handle this logic in build usually, but keeping simple int here.
      // 0xFFFFFFFF works for light mode. For dark mode, we might want a darker default.
    }
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty && _contentController.text.trim().isEmpty) {
      Navigator.pop(context); // Empty note, just go back
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (widget.noteToEdit == null) {
        await ref.read(noteRepositoryProvider).addNote(
          _titleController.text.trim(),
          _contentController.text.trim(),
          _selectedColor,
        );
      } else {
        final updated = NoteModel(
          id: widget.noteToEdit!.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          date: widget.noteToEdit!.date,
          lastEdited: DateTime.now(),
          colorValue: _selectedColor,
        );
        await ref.read(noteRepositoryProvider).updateNote(updated);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);

    // Logic to handle "Default" color displaying correctly in Dark Mode
    Color bgColor = Color(_selectedColor);
    if (isDark && _selectedColor == 0xFFFFFFFF) {
      bgColor = const Color(0xFF1E1E1E); // Default Dark Card
    }

    final textColor = (isDark && _selectedColor == 0xFFFFFFFF) ? Colors.white : Colors.black87;

    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: textColor),
          actions: [
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.only(right: 16), child: CircularProgressIndicator())),
            if (!_isLoading)
              TextButton(
                onPressed: _save,
                child: Text("Save", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              )
          ],
        ),
        bottomNavigationBar: _buildColorPalette(isDark),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                decoration: InputDecoration(
                  hintText: "Title",
                  hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                  border: InputBorder.none,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  style: TextStyle(fontSize: 16, color: textColor, height: 1.5),
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: "Note content...",
                    hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPalette(bool isDark) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: isDark ? Colors.black26 : Colors.transparent,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _colors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final colorInt = _colors[index];
          final color = Color(colorInt);
          final isSelected = _selectedColor == colorInt;

          return GestureDetector(
            onTap: () => setState(() => _selectedColor = colorInt),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black87 : Colors.grey.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [if (isSelected) const BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.black87, size: 20) : null,
            ),
          );
        },
      ),
    );
  }
}