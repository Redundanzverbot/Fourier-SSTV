Button[] buttons = new Button[5];

float buttonHeight;


class Button{
  
  int index;
  color c;
  float pos;
  int[] samples;
  float[] amplitudes;
  
  
  Button(int i, color col){
    c = col;
    index = i;
    pos = (i + 1) * 30 + i * buttonHeight;
  }
  
  
  boolean isPressed(int my){
    return my >= pos && my <= pos + buttonHeight;
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
  
  
  void processAudioData(){
    
    background(0);
    for (Button b : buttons) b.show();
    noStroke();
    
    float deltaY = float(height) / imgHeight;
    
    amplitudes = new float[imgWidth * imgHeight];
    
    // Auslesen der Basis-Frequenz
    float baseValue = ampOfFreq(1);
    
    // Skalieren der Amplituden-Werte
    for (int i = 2; i < amplitudes.length + 2; i++){
    
      // Der Farbwert wird als Prozentwert an der Basisfrequenz interpretiert
      float val = ampOfFreq(i);
      val /= baseValue;
      amplitudes[i - 2] = val;
      
      fill(val * red(c), val * green(c), val * blue(c));
      rect(deltaY * (i % imgWidth), deltaY * (floor(i / imgWidth)), deltaY, deltaY);
      
      /*
      if ((i - 1) % 200 == 0){
        println(floor(i / 200), "%");
      }
      */
    }
    
    if (index == 0){
      amplitudes = gaussBlur(amplitudes);
    }
  }
  
  
  float ampOfFreq(int xi){
  
    PVector avg = new PVector(0, 0);
    int N = samples.length;
    
    // Summe bilden
    for (int n = 0; n < N; n++){
    
      // Berechnung der komplexen Zahl
      PVector samplePoint = new PVector(cos(-xi * n * TAU / N), sin(-xi * n * TAU / N));
      samplePoint.mult(samples[n]);
      
      avg.add(samplePoint);
    }
    
    avg.div(N);
    
    return avg.mag();
  }
  
  
  void show(){
    
    if (index == 0){
      stroke(255, 255, 255);
      strokeWeight(5);
      noFill();
      rect(width - 200 - int(recording == this) * 100, pos, 310, buttonHeight, 50, 0, 0, 50);
      
      fill(255);
      noStroke();
      textSize(80);
      textAlign(CENTER, CENTER);
      text("K", width - 100, pos + buttonHeight * 0.5);
    }
    
    else {
      fill(c);
      rect(width - 200 - int(recording == this) * 100, pos, 300, buttonHeight, 50, 0, 0, 50);
    }
    
    if (samples != null){
      stroke(0);
      strokeWeight(5);
      fill(255);
      circle(width - 250, pos + buttonHeight * 0.5, 35);
    }
  }
}
