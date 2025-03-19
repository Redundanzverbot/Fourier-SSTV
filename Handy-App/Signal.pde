float zoom = 1;
float mult = 1.0;


class Signal{

  
  int[] samples;
  float[] amplitudes;
  float[] calibration;
  
  
  Signal(int[] sampleVals){
    
    println("INITIALISIERUNG BEGONNEN");
    
    samples = sampleVals;
    
    readFrequencies();
    
    calibrating = false;
    
    println("KALIBRIERUNG ABGESCHLOSSEN");
    
    calibration = gaussBlur(calibration);
    calibration = gaussBlur(calibration);
    
    float deltaX = float(width) / imgHeight;
    for (int i = 0; i < 160*120; i++){
      fill(calibration[i] * 255);
      rect(width - deltaX * (floor(i / imgWidth)), deltaX * (i % imgWidth), deltaX, deltaX);
    }
  }
  
  
  void readFrequencies(){
    
    noStroke();
    
    float deltaX = float(width) / imgHeight;
    
    calibration = new float[imgWidth * imgHeight];
    amplitudes = new float[imgWidth * imgHeight];
    
    // Auslesen der Basis-Frequenz
    float baseValue = ampOfFreq(1);
    
    // Skalieren der Amplituden-Werte
    for (int i = 2; i < amplitudes.length + 2; i++){
    
      // Der Farbwert wird als Prozentwert an der Basisfrequenz interpretiert...
      float val = ampOfFreq(i);
      val /= baseValue;
      
      if (calibrating){
        calibration[i - 2] = val;
      } else {
        amplitudes[i - 2] = val / max(1, calibration[i - 2]);
      }
      
      fill(val * 255);
      
      rect(width - deltaX * (floor((i - 2) / imgWidth)), deltaX * ((i - 2) % imgWidth), deltaX, deltaX);

      
      //rect(((i-2) % imgWidth) * deltaX, floor((i - 2) / imgWidth) * deltaX, deltaX + 1, deltaX + 1);
      
      if ((i - 1) % 200 == 0){
        println(floor(i / 200), "%");
      }
    }
  }
  
  
  float ampOfFreq(int n){
    
    PVector avg = new PVector(0, 0);
    int N = samples.length;
    
    for (int k = 0; k < N; k++){
      float f = samples[k];
      PVector samplePoint = new PVector(cos(TAU / N * n * k), sin(TAU / N * n * k));
      samplePoint.mult(f);
      avg.add(samplePoint);
    }
    
    avg.div(N);
    
    return 2 * avg.mag();
  }
  
  
  void showImage(){
    
    noStroke();
    
    float deltaX = width / 200.0;
    for (int x = 0; x < 200; x++){
      for (int y = 0; y < 100; y++){
        fill(calibration[x + y * 200] * 255 * mult);
        rect(x * deltaX, y * deltaX, deltaX, deltaX);
      }
    }
  }
  
  
  void showWave(){
    
    background(35);
    strokeWeight(2);
    stroke(50);
    line(width / 2, 0, width / 2, height);
    stroke(235);
    
    float deltaY = (float) height / samples.length * zoom;
    
    for (int i = 0; i < floor((float) samples.length / zoom) - 1; i++){
      
      float x1 = width / 2 +     samples[i] / pow(2, 15) * width * 0.5;
      float x2 = width / 2 + samples[i + 1] / pow(2, 15) * width * 0.5;
      line(x1, deltaY * i, x2, deltaY * (i + 1));
    }
  }
}


float[] gaussBlur(float[] array){
  
  float[] weights = {0.26, 0.21, 0.11, 0.04, 0.01};  
  float[] result = array;
  
  for (int i = 4; i < array.length - 4; i++){
    float sum = 0;
    for (int j = -4; j <= 4; j++){
      sum += array[i + j] * weights[abs(j)];
    }
    result[i] = sum;
  }
  
  return result;
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
