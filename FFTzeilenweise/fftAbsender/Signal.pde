// Erstellen und Speichern des Tongemischs


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
    colorMode = mode;
    
    // Amplituden-Array
    amps = new int[(img.width+1) * img.height];
    
    // Zeilenweise erstellen
    for (int y = 0; y < img.height; y++){
      
      // Definiere die Basisfrequenz der Zeile
      amps[y * (img.width+1)] = 255;
      
      // Arrays je nach Farbkanal
      for (int x = 0; x < img.width; x++){
        
        int imageIndex = y * (img.width)   + x;
        int arrayIndex = y * (img.width+1) + x + 1;
        
        switch (colorMode){
          case 0:
          amps[arrayIndex] = (int) brightness(img.pixels[imageIndex]);
          break;
          
          case 1:
          amps[arrayIndex] = brightness(img.pixels[imageIndex]) / 255.0 > thresh ? 1 : 0;
          break;
          
          case 2:
          amps[arrayIndex] = (int) red(img.pixels[imageIndex]);
          break;
          
          case 3:
          amps[arrayIndex] = (int) green(img.pixels[imageIndex]);
          break;
          
          case 4:
          amps[arrayIndex] = (int) blue(img.pixels[imageIndex]);
          break;
        }
      }
    }
    
    // Erstelle das Tongemisch mit den entsprechenden Parametern
    samples = inverseFourier(amps);
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
