import 'package:speech_to_text/speech_to_text.dart';

/// Service that manages speech recognition using [SpeechToText].
class SpeechService {
  final SpeechToText _speech = SpeechToText();
  final void Function(String text) _onFinal;
  final void Function(String message) _onError;

  bool _isListening = false;
  bool _isInitialized = false;

  /// Whether the service is currently listening.
  bool get isListening => _isListening;

  SpeechService({
    required void Function(String text) onFinal,
    required void Function(String message) onError,
  })  : _onFinal = onFinal,
        _onError = onError;

  /// Initializes the speech recognizer and requests permissions if needed.
  Future<bool> initialize() async {
    try {
      _isInitialized = await _speech.initialize(
        onError: (error) => _onError(error.errorMsg),
      );
      if (!_isInitialized) {
        _onError('Microphone permission denied');
      }
    } catch (e) {
      _isInitialized = false;
      _onError('Initialization failed: $e');
    }
    return _isInitialized;
  }

  /// Starts listening for speech and emits recognized words through
  /// [onResult]. The [_onFinal] callback is triggered when the final result
  /// is received.
  void startListening({Function(String)? onResult}) {
    if (_isListening) return;
    if (!_isInitialized) {
      _onError('Speech service not initialized');
      return;
    }

    try {
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
    } catch (e) {
      _onError('Failed to start listening: $e');
    }
  }

  /// Stops listening for speech.
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speech.stop();
      await _speech.cancel();
    } catch (e) {
      _onError('Failed to stop listening: $e');
    } finally {
      _isListening = false;
    }
  }
}
