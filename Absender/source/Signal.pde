Signal s;


class Signal {
  
  
  int[] freqs;
  int[] amps;
  
  float[] samples;
  AudioSample sample;
  
  int sampleRate = 44100;
  int blockAlign = 2;
  
  int colorMode;
  
  
  Signal(PImage img, int mode){
    
    // Laden des Bildes
    img.resize(120, 160);
    colorMode = mode;
    
    // Amplituden-Array
    amps = new int[img.width * img.height + 1];
    
    // Definieren der Basis-Frequenz
    amps[0] = 255;
    
    // Arrays je nach Farbkanal
    for (int i = 1; i < amps.length; i++){
      
      switch (colorMode){
        case 0:
        amps[i] = (int) brightness(img.pixels[i - 1]);
        break;
        
        case 1:
        amps[i] = (int) red(img.pixels[i - 1]);
        break;
        
        case 2:
        amps[i] = (int) green(img.pixels[i - 1]);
        break;
        
        case 3:
        amps[i] = (int) blue(img.pixels[i - 1]);
        break;
      }
    }
    
    samples = inverseFourier(amps, sampleRate);
  }
  
  
  // Erstellen des AudioSamples
  void updateSample(PApplet sketchObject){
    sample = new AudioSample(sketchObject, samples, sampleRate);
  }
  
  
  // Abspeichern der .wav-Datei
  byte[] exportWav(){
    
    byte[] bytes = new byte[samples.length * blockAlign + 44];
    
    // RIFF chunk descriptor
    bytes = insert(bytes, stringToBE("RIFF"), 0);
    bytes = insert(bytes, intToLE(bytes.length - 8, 4), 4);
    bytes = insert(bytes, stringToBE("WAVE"), 8);
    
    // format subchunk
    bytes = insert(bytes, stringToBE("fmt "), 12);
    bytes = insert(bytes, intToLE(16, 4), 16);
    bytes = insert(bytes, intToLE(1, 2), 20);
    bytes = insert(bytes, intToLE(1, 2), 22);
    bytes = insert(bytes, intToLE(sampleRate, 4), 24);
    bytes = insert(bytes, intToLE(sampleRate * blockAlign, 4), 28);
    bytes = insert(bytes, intToLE(blockAlign, 2), 32);
    bytes = insert(bytes, intToLE(blockAlign * 8, 2), 34);
    
    // data subchunk
    bytes = insert(bytes, stringToBE("data"), 36);
    bytes = insert(bytes, intToLE(bytes.length - 44, 4), 40);
    
    for (int i = 0; i < samples.length; i++){
      
      // Beachte -1 in pow(): Die Range beinhaltet sowohl den positiven als auch negativen Zahlenbereich
      int sampleVal = int(samples[i] * pow(2, (8 * blockAlign) - 1));
      bytes = insert(bytes, intToLE(sampleVal, blockAlign), 44 + i * blockAlign);
    }
    
    return bytes;
  }
}
