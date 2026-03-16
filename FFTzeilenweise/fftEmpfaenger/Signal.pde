Signal s;


class Signal{
  
  
  float[] amps;
  int sampleRate;
  
  float[] samples;
  float[] amplitudes;
  
  
  Signal(String fileName){
    
    // .wav-Datei auslesen
    byte[] bytes = loadBytes(fileName);
    int blockAlign = LEtoInt(bytes, 32, 2);

    samples = new float[(bytes.length - 44) / blockAlign];
    
    // Auslesen der Abtastwerte
    for (int i = 0; i < samples.length; i++){
      int val = LEtoInt(bytes, 44 + i * blockAlign, blockAlign);
      samples[i] = (float) val / pow(2, (8 * blockAlign) - 1);
    }
    
    // Frequenzen auslesen
    readFrequencies();
  }
  
  
  // Füllt das Frequenz-Array
  void readFrequencies(){
    
    amplitudes = new float[160 * 120];
    
    // Zeilenweise auslesen
    for (int y = 0; y < 160; y++){
      
      // Auslesen der Basis-Frequenz
      float baseValue = dft(y*(120+1));
    
      // Skalieren der Amplituden-Werte
      for (int x = 0; x < 120; x++){
      
        // Der Farbwert wird als Prozentwert an der Basisfrequenz interpretiert.
        float val = dft(y*(120+1) + 2 + x);
        val /= baseValue;
        
        amplitudes[y*120+x] = val;
      }
    }
  }
  
  
  // Diskrete Fourier-Transformation
  float dft(int xi){
    
    int N = samples.length;
    float[] avg = new float[] {0, 0};
    
    // Komplexe Summe bilden
    for (int n = 0; n < N; n++){
      avg[0] += samples[n] * cos(-xi * n * TAU / N); // Realteil
      avg[1] += samples[n] * sin(-xi * n * TAU / N); // Imaginärteil
    }
    
    return dist(0, 0, avg[0], avg[1]);
  }
}


// Konvertiere Little Endian Bytes in Integer
int LEtoInt(byte[] bytes, int startByte, int blockLength){
  
  int result = 0;
  
  for (int i = blockLength - 1; i >= 0; i--){
    int val = bytes[startByte + i];
    if (i < blockLength - 1 && val < 0) val = 256 + val;
    val *= pow(2, i * 8);
    result += val;
  }
  
  return result;
}
