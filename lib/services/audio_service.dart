import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

/// Service for recording audio notes.
class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String? _filePath;

  /// Starts a new recording and saves it to a temporary file.
  Future<void> startRecording() async {
    if (_recorder.isRecording) return;
    final dir = await getApplicationDocumentsDirectory();
    _filePath = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder.openRecorder();
    await _recorder.startRecorder(toFile: _filePath, codec: Codec.aacADTS);
  }

  /// Stops the recording and returns the saved file path.
  Future<String?> stopRecording() async {
    if (!_recorder.isRecording) return _filePath;
    await _recorder.stopRecorder();
    await _recorder.closeRecorder();
    return _filePath;
  }
}
