import 'package:flutter/cupertino.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechApi {
  static final _speech = SpeechToText();
  static final flutterTts = FlutterTts();

  static Future<void> toggleRecording({
    required Function(String text) onResult,
    required ValueChanged<bool> onListening,
  }) async {
    if (_speech.isListening) {
      _speech.stop();
    }
    final isAvailable = await _speech.initialize(
        onStatus: (status) {
          debugPrint('status $status');
          debugPrint("_speech.isListening ${_speech.isListening.toString()}");
          onListening(_speech.isListening);
        },
        onError: (e) => debugPrint('Error $e'));

    if (isAvailable) {
      debugPrint('isAvailable $isAvailable');
      _speech.listen(onResult: (value) => onResult(value.recognizedWords));
    }
  }

  static Future speak(String text) async {
    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    } else {
      await flutterTts.speak('I cant help you');
    }
  }
}
