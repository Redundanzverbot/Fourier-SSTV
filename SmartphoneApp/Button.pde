Button[] buttons = new Button[5];
Button recording;
int bWidth;
int bHeight = 400;

float[] gaussWeights = {0.26, 0.21, 0.11, 0.04, 0.01};


class Button{
  
  
  int index;
  color c;
  float pos;
  
  int[] samples;
  float[] amplitudes;
  
  
  Button(int i, color col){
    index = i;
    c = col;
    pos = (i + 1) * 30 + i * bWidth;
  }
  
  
  // Ausführung nachdem alle Samples gesammelt wurden
  void processAudioData(){
    
    background(0);
    fill(255);
    rect(0, 0, width, res*imgHeight);
    for (Button b : buttons) b.show();
    
    amplitudes = new float[imgWidth * imgHeight];
    
    // Auslesen der Basis-Frequenz 1 Hertz
    float baseValue = dft(1);
    
    // Skalieren der Amplituden-Werte
    for (int i = 2; i <= amplitudes.length + 1; i++){
    
      // Der Farbwert wird als Prozentwert an der Basisfrequenz interpretiert
      float val = dft(i);
      val /= baseValue;
      amplitudes[i - 2] = val;
      
      fill(val * red(c), val * green(c), val * blue(c));
      rect(res * (i % imgWidth), res * (floor(i / imgWidth)), res, res);
    }
    
    // Blurre die Kalibrierung
    if (index == 0) amplitudes = gaussBlur(amplitudes);
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
  
  
  float[] gaussBlur(float[] array){
    
    float[] result = new float[array.length];
    
    for (int i = 4; i < array.length - 4; i++){
      float sum = 0;
      for (int j = -4; j <= 4; j++){
        sum += array[i + j] * gaussWeights[abs(j)];
      }
      result[i] = sum;
    }
    
    return result;
  }
  
  
  boolean isPressed(int mx){
    return mx >= pos && mx <= pos + bWidth;
  }
  
  
  void show(){
    
    // Rechteck zeichnen
    fill(c);
    rect(pos, height - bHeight - int(recording == this) * 100, bWidth, bHeight + 150, 50, 50, 0, 0);
    
    // "K" anzeigen
    if (index == 0) {
      fill(0);
      text("K", pos + .5*bWidth, height - bHeight + 100);
    }
    
    fill(255);
    
    // Indikator, ob bereits geladen
    if (samples != null) circle(pos + .5*bWidth, height - bHeight - 30, 35);
  }
}
