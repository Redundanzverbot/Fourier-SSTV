float zoom = 200;


class Signal {
  
  int[] freqs;
  int[] amps;
  
  float[] samples;
  AudioSample sample;
  
  int sampleRate = 44100;
  int blockAlign = 2;
  
  int colorMode;
  
  
  Signal(PImage image, int mode){
    
    image.resize(160, 120);
    colorMode = mode;
    
    // Anlegen der Arrays
    freqs = new int[image.width * image.height + 1];
    amps = new int[image.width * image.height + 1];
    
    // Definieren der Basis-Frequenz
    freqs[0] = 1;
    amps[0] = 255;
    
    // Arrays bestücken
    for (int i = 1; i < amps.length; i++){
      freqs[i] = i + 1;
      
      switch (colorMode){
        case 0:
        amps[i] = (int) brightness(image.pixels[i - 1]);
        break;
        
        case 1:
        amps[i] = (int) red(image.pixels[i - 1]);
        break;
        
        case 2:
        amps[i] = (int) green(image.pixels[i - 1]);
        break;
        
        case 3:
        amps[i] = (int) blue(image.pixels[i - 1]);
        break;
      }
    }
    
    samples = inverseFourier(freqs, amps, sampleRate);
  }
  
  
  // Debug-Konstruktor
  Signal(int[] frequencies, int[] amplitudes, int sr){
    
    freqs = frequencies;
    sampleRate = sr;
    amps = amplitudes;
    
    samples = inverseFourier(freqs, amps, sampleRate);
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
      // Beachte 7: Die Range beinhaltet sowohl den positiven als auch negativen Zahlenbereich
      int sampleVal = int(samples[i] * pow(2, (8 * blockAlign) - 1));
      bytes = insert(bytes, intToLE(sampleVal, blockAlign), 44 + i * blockAlign);
    }
    
    return bytes;
  }
  
  
  // Anzeigen der Audiowelle
  void show(){
    
    int amount = width / 2 - 75;
    int skip = samples.length / amount;
    float maxY = (float) imgHeight * 0.5 * deltaX;
    
    stroke(200);
    strokeWeight(2);
    pushMatrix();
    translate(width / 2.0 + 25, 50 + maxY);
    
    line(0, 0, width, 0);
    stroke(buttons[colorMode + 1].c);
    
    for (int i = 0; i < amount - 1; i++){
      line(i, -samples[i * skip] * maxY, i + 1, -samples[(i + 1) * skip] * maxY);
    }
    popMatrix();
  }
}
