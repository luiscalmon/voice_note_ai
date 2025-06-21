import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../services/speech_service.dart';
import 'note_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final SpeechService _speechService;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speechService = SpeechService(onFinal: _handleFinalSpeech);
    _initialize();
  }

  Future<void> _initialize() async {
    await _speechService.initialize();
  }

  void _handleFinalSpeech(String text) {
    _processFinalSpeech(text);
  }

  Future<void> _processFinalSpeech(String text) async {
    await _speechService.stopListening();
    setState(() {
      _isListening = false;
    });

    if (text.isEmpty) return;

    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      createdAt: DateTime.now(),
    );

    await context.read<NotesProvider>().addNote(note);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved')),
      );
    }
  }

  void _startListening() {
    if (_isListening) return;
    _speechService.startListening();
    setState(() {
      _isListening = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NotesProvider>().notes;
    return Scaffold(
      appBar: AppBar(
        title: const Text('VoiceNote AI'),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note.text),
            subtitle: Text(
              '${note.createdAt}',
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NoteDetailScreen(note: note),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startListening,
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
