import 'package:flutter_tts/flutter_tts.dart';

/// Síntesis de voz corta para confirmaciones en marcación.
class TtsFeedback {
  TtsFeedback._();

  static final TtsFeedback instance = TtsFeedback._();

  /// En MAYÚSCULAS el motor suele deletrear (p. ej. M-A-R-C-A-C-I-O-N).
  static const _marcacionCorrectaPhrase = 'Marcación correcta';

  FlutterTts? _tts;
  var _ready = false;

  Future<String> _resolveSpanishLanguage(FlutterTts tts) async {
    const candidates = ['es-MX', 'es-ES', 'es-US', 'es'];
    for (final lang in candidates) {
      if (await tts.isLanguageAvailable(lang) == true) {
        return lang;
      }
    }
    return 'es-ES';
  }

  Future<void> _ensureReady() async {
    if (_ready) return;
    final tts = FlutterTts();
    final lang = await _resolveSpanishLanguage(tts);
    await tts.setLanguage(lang);
    await tts.setSpeechRate(0.45);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);
    await tts.awaitSpeakCompletion(true);
    _tts = tts;
    _ready = true;
  }

  Future<void> speakMarcacionCorrecta() async {
    try {
      await _ensureReady();
      await _tts?.stop();
      await _tts?.speak(_marcacionCorrectaPhrase);
    } catch (_) {
      // Si TTS no está disponible, la marcación sigue sin voz.
    }
  }

  Future<void> dispose() async {
    try {
      await _tts?.stop();
    } catch (_) {}
    _tts = null;
    _ready = false;
  }
}
