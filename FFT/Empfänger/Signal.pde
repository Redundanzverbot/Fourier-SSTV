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
    
    amplitudes = new float[105 * 140];
    
    float[] fftSpectrum = magnitudes(fft(toImaginary(samples)));
    
    for (int i = 0; i < amplitudes.length; i++){
      amplitudes[i] = fftSpectrum[i+2] / fftSpectrum[1];
    }
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
