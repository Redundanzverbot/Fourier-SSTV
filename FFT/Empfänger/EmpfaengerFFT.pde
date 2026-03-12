import processing.sound.*;


int res = 5;


void settings(){
  size(105*res, 140*res);
}


void setup(){
  
  background(255, 0, 0);
  noStroke();
  
  // Signal laden und analysieren
  s = new Signal("toneSignal.wav");
  
  // Bildpunkte zeichnen
  for (int i = 0; i < s.amplitudes.length; i++){
    fill(s.amplitudes[i] * 255);
    rect((i % 105) * res, floor(i / 105) * res, res, res);
  }
  
  //saveFrame("result.png");
}


void draw(){}


// Berechne die Beträge der komplexen Zahlen (berücksichtige Nyquist-Shannon)
float[] magnitudes(float[][] list){
  
  float[] result = new float[int(.5*list.length)];
  
  for (int i = 0; i < result.length; i++){
    result[i] = dist(0, 0, list[i][0], list[i][1]);
  }
  
  return result;
}


// Zero-padding für Imaginär-Teile
float[][] toImaginary(float[] re){
  
  float[][] result = new float[re.length][2];
  for (int i = 0; i < re.length; i++) result[i] = new float[] {re[i], 0};
  
  return result;
}


// Fast Fourier Transformation (Cooley-Tukey, Radix-2)
float[][] fft(float[][] f) {
  
  // Abbruchbedingung
  if (f.length <= 1) return f;
  
  int n = f.length;
  int hn = int(.5*n);
  
  // Split into two arrays
  float[][] even = new float[hn][2];
  float[][] odd = new float[hn][2];
  
  for (int k = 0; k < hn; k++){
    even[k] = f[2*k];
    odd[k] = f[2*k+1];
  }
  
  // Rekursiver Aufruf
  even = fft(even);
  odd = fft(odd);
  
  // Ergebnis berechnen
  float[][] result = new float[n][2];

  for (int k = 0; k < hn; k++){
    
    float[] twiddleFactor = new float[] {cos(-TWO_PI * k / n), sin(-TWO_PI * k / n)};
    float[] twiddledOdd   = cMult(odd[k], twiddleFactor);
    
    result[k   ] = cAdd(even[k], twiddledOdd);
    result[k+hn] = cSub(even[k], twiddledOdd);
  }

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
