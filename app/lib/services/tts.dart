import 'package:flutter_tts/flutter_tts.dart';

/// Audio de pronunciación con el motor de voz del propio teléfono
/// (no necesitas grabar ni subir archivos de audio).
class Tts {
  Tts._();
  static final Tts instance = Tts._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    await _tts.setLanguage('en-US');
    await _tts.awaitSpeakCompletion(true);
    _ready = true;
  }

  Future<void> speak(String text, {double rate = 0.45}) async {
    await _init();
    await _tts.setSpeechRate(rate);
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
