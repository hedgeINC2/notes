import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'db_helper.dart'; // Import the file created above

void main() {
  runApp(const MyApp());
}

// 1. Color Palette (Attractive Pastels)
final List<Color> cardColors = [
  const Color(0xFFFFAB91), // Orange
  const Color(0xFFFFCC80), // Yellow
  const Color(0xFFE6EE9B), // Lime
  const Color(0xFF80DEEA), // Cyan
  const Color(0xFFCF93D9), // Purple
  const Color(0xFFF48FB1), // Pink
  const Color(0xFFB0BEC5), // Grey Blue
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quick Notes',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: const Color(0xFF1F1F1F),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.white),
      ),
      home: const NotesScreen(),
    );
  }
}

// 2. Home Screen
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late List<Note> notes;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);
    notes = await DatabaseHelper.instance.readAllNotes();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notes',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
          ? const Center(
              child: Text(
                'No notes yet!',
                style: TextStyle(color: Colors.white54, fontSize: 18),
              ),
            )
          : MasonryGridView.count(
              padding: const EdgeInsets.all(8),
              itemCount: notes.length,
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemBuilder: (context, index) {
                final note = notes[index];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NoteDetailScreen(note: note),
                      ),
                    );
                    refreshNotes();
                  },
                  child: Card(
                    color: cardColors[note.colorIndex % cardColors.length],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            note.content.length > 100
                                ? '${note.content.substring(0, 100)}...'
                                : note.content,
                            style: GoogleFonts.poppins(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            note.time,
                            style: GoogleFonts.lato(
                              fontSize: 10,
                              color: Colors.black45,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amberAccent,
        foregroundColor: Colors.black,
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const NoteDetailScreen()),
          );
          refreshNotes();
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

// 3. Edit/Add Screen
class NoteDetailScreen extends StatefulWidget {
  final Note? note;

  const NoteDetailScreen({super.key, this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late int colorIndex;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      colorIndex = widget.note!.colorIndex;
    } else {
      // Random color for new note
      colorIndex = Random().nextInt(cardColors.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        actions: [
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await DatabaseHelper.instance.delete(widget.note!.id!);
                Navigator.of(context).pop();
              },
            ),
          IconButton(icon: const Icon(Icons.check), onPressed: _saveNote),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 8),
            // Display date at top of content like Apple Notes
            Text(
              DateFormat('MMMM dd, HH:mm').format(DateTime.now()),
              style: TextStyle(
                color: cardColors[colorIndex % cardColors.length],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: null, // Grows with content
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Type something...',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _saveNote() async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty && content.isEmpty) return;

    final note = Note(
      id: widget.note?.id,
      title: title,
      content: content,
      time: DateFormat('MMM dd, yyyy').format(DateTime.now()),
      colorIndex: colorIndex,
    );

    if (widget.note == null) {
      await DatabaseHelper.instance.create(note);
    } else {
      await DatabaseHelper.instance.update(note);
    }

    Navigator.of(context).pop();
  }
}
