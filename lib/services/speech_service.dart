import 'package:speech_to_text/speech_to_text.dart';

/// Service that manages speech recognition using [SpeechToText].
class SpeechService {
  final SpeechToText _speech = SpeechToText();
  final void Function(String text) _onFinal;

  bool _isListening = false;

  /// Whether the service is currently listening.
  bool get isListening => _isListening;

  SpeechService({required void Function(String text) onFinal})
      : _onFinal = onFinal;

  /// Initializes the speech recognizer and requests permissions if needed.
  Future<bool> initialize() async {
    final available = await _speech.initialize();
    return available;
  }

  /// Starts listening for speech and emits recognized words through
  /// [onResult]. The [_onFinal] callback is triggered when the final result
  /// is received.
  void startListening({Function(String)? onResult}) {
    if (_isListening) return;

    _speech.listen(onResult: (result) {
      final words = result.recognizedWords;
      if (words.isNotEmpty) {
        onResult?.call(words);
      }
      if (result.finalResult) {
        _onFinal(words);
      }
    });
    _isListening = true;
  }

  /// Stops listening for speech.
  Future<void> stopListening() async {
    if (!_isListening) return;

    await _speech.stop();
    _isListening = false;
  }
}
