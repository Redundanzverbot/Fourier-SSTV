float zoom = 50;


class Signal{
  
  float[] amps;
  int sampleRate;
  
  float[] samples;
  float[] amplitudes;
  
  
  Signal(String fileName){
    
    byte[] bytes = loadBytes(fileName);
    int blockAlign = LEtoInt(bytes, 32, 2);
    
    samples = new float[(bytes.length - 44) / blockAlign];
    
    // Auslesen der Abtastwerte
    for (int i = 0; i < samples.length; i++){
      int val = LEtoInt(bytes, 44 + i * blockAlign, blockAlign);
      samples[i] = (float) val / pow(2, (8 * blockAlign) - 1);
    }
    
    readFrequencies();
  }
  
  
  void readFrequencies(){    
    
    amplitudes = new float[160 * 120];
    
    // Auslesen der Basis-Frequenz
    float baseValue = dft(1);
    
    // Skalieren der Amplituden-Werte
    for (int i = 2; i < 160 * 120 + 2; i++){
    
      // Der Farbwert wird als Prozentwert an der Basisfrequenz interpretiert.
      float val = dft(i);
      val /= baseValue;
      
      amplitudes[i - 2] = val;
    }
  }
  
  
  float dft(int xi){
  
    PVector avg = new PVector(0, 0);
    int N = samples.length;
    
    // Summe bilden
    for (int n = 0; n < N; n++){
    
      // Berechnung der komplexen Zahl
      PVector samplePoint = new PVector(cos(-xi * n * TAU / N), sin(-xi * n * TAU / N));
      samplePoint.mult(samples[n]);
      
      avg.add(samplePoint);
    }
    
    return avg.mag();
  }
  
  
  /*
  void show(){
    
    float deltaX = (float) width / samples.length;
    float maxY = (float) height / 2;
    
    background(35);
    stroke(50);
    pushMatrix();
    translate(0, height / 2);
    
    line(0, 0, width, 0);
    
    stroke(235);
    for (int i = 0; i < floor((float) samples.length / zoom) - 1; i++){
      line(deltaX * i * zoom, -samples[i] * maxY, deltaX * (i + 1) * zoom, -samples[i + 1] * maxY);
    }
    popMatrix();
  }
  */
}


int LEtoInt(byte[] bytes, int startByte, int blockLength){
  
  int result = 0;
  
  for (int i = blockLength - 1; i >= 0; i--){
    int val = bytes[startByte + i];
    if (i < blockLength - 1 && val < 0){
      val = 256 + val;
    }
    val *= pow(2, i * 8);
    
    result += val;
  }
  
  return result;
}
