// Buttons zum Auswählen des Modus


Button[] buttons = new Button[5];
Button recording;
int bWidth;
int bHeight = 400;
float thresh = 0.5;


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
    
    amplitudes = new float[imgWidth[mode] * imgHeight[mode]];
    
    // Zeilenweise auslesen
    for (int y = 0; y < imgHeight[mode]; y++){
    
      // Auslesen der Basis-Frequenz 1 Hertz
      float baseValue = dft(y*(imgWidth[mode]+1) + 1);
      
      // Skalieren der Amplituden-Werte
      for (int x = 0; x < imgWidth[mode]; x++){
      
        // Der Farbwert wird als Prozentwert an der Basisfrequenz interpretiert
        float val = dft(y*(imgWidth[mode]+1) + 2 + x);
        val /= baseValue;
        
        amplitudes[y*120+x] = val;
        
        if (index == 0) fill(val > thresh ? 255 : 0);
        else fill(val * red(c), val * green(c), val * blue(c));
        rect(res * x, res * y, res, res);
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
  
  
  boolean isPressed(int mx){
    return mx >= pos && mx <= pos + bWidth;
  }
  
  
  void show(){
    
    // Rechteck zeichnen
    fill(c);
    rect(pos, height - bHeight - int(recording == this) * 100, bWidth, bHeight + 150, 50, 50, 0, 0);
    
    // "K" anzeigen
    if (index == 0){
      fill(0);
      rect(height - thresh * bHeight, bWidth, thresh * bHeight, bWidth);
    }
    
    fill(255);
    
    // Indikator, ob bereits geladen
    if (samples != null) circle(pos + .5*bWidth, height - bHeight - 30, 35);
  }
}
