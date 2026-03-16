// Methoden zum Berechnen der Fast Fourier-Transform


// Fast Fourier Transformation (Cooley-Tukey, Radix-2)
float[][] fft(float[][] f) {
  
  // Abbruchbedingung
  if (f.length <= 1) return f;
  
  int n = f.length;
  int hn = int(.5*n);
  
  // In zwei Arrays aufteilen
  float[][] even = new float[hn][2];
  float[][] odd = new float[hn][2];
  
  for (int k = 0; k < hn; k++){
    even[k] = f[2*k];
    odd[k]  = f[2*k+1];
  }
  
  // Rekursiver Aufruf
  even = fft(even);
  odd  = fft(odd);
  
  
  // Ergebnis berechnen
  float[][] result = new float[n][2];

  for (int k = 0; k < hn; k++){
    
    float[] twiddleFactor = {cos(k * -TWO_PI / n), sin(k * -TWO_PI / n)};
    float[] twiddledOdd   = cMult(odd[k], twiddleFactor);
    
    result[k   ] = cAdd(even[k], twiddledOdd);
    result[k+hn] = cSub(even[k], twiddledOdd);
  }

  return result;
}


// Berechne die Beträge der komplexen Zahlen (berücksichtige Nyquist-Shannon)
float[] magnitudes(float[][] list){
  
  float[] result = new float[int(.5*list.length)];
  
  for (int i = 0; i < result.length; i++) result[i] = dist(0, 0, list[i][0], list[i][1]);
  
  return result;
}


// Normalisiere das Spektrum
float[] normSpectrum(float[] list){
  
  float[] result = new float[list.length];
  float sum = 0;
  
  for (float f : list) sum += f;
  
  for (int i = 0; i < list.length; i++) result[i] = list[i] / (2*sum);
  
  for (int i = 0; i < list.length; i++) result[i] = pow(result[i], 2);
  
  return result;
}


// Zero-padding für Imaginär-Teile
float[][] toImaginary(float[] re){
  
  float[][] result = new float[re.length][2];
  for (int i = 0; i < re.length; i++) result[i] = new float[] {re[i], 0};
  
  return result;
}


// Hilfsfunktionen für komplexe Zahlen
float[] cAdd(float[] a, float[] b) {
  return new float[]{a[0] + b[0], a[1] + b[1]};
}

float[] cSub(float[] a, float[] b) {
  return new float[]{a[0] - b[0], a[1] - b[1]};
}

float[] cMult(float[] a, float[] b) {
  return new float[]{a[0]*b[0] - a[1]*b[1], a[0]*b[1] + a[1]*b[0]};
}
