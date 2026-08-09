import 'synth_service_stub.dart' if (dart.library.js_interop) 'synth_service_web.dart';

class SynthService {
  void playInstrument(String id) {
    SynthServicePlatform.play(id);
  }
  
  void pauseInstrument(String id) { 
    // Since it's continuous synthesis, pausing means stopping the oscillators
    SynthServicePlatform.stop(id);
  }
  
  void setInstrumentTuning(String id, double freq) {
    SynthServicePlatform.setFrequency(freq);
  }
}

final synthService = SynthService();
