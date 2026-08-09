import 'dart:js_interop';

@JS('window.synthEngine.play')
external void _synthPlay(JSString instrumentId);

@JS('window.synthEngine.stop')
external void _synthStop(JSString instrumentId);

@JS('window.synthEngine.setFrequency')
external void _synthSetFrequency(JSNumber freq);

class SynthServicePlatform {
  static void play(String instrumentId) {
    _synthPlay(instrumentId.toJS);
  }

  static void stop(String instrumentId) {
    _synthStop(instrumentId.toJS);
  }

  static void setFrequency(double freq) {
    _synthSetFrequency(freq.toJS);
  }
}
