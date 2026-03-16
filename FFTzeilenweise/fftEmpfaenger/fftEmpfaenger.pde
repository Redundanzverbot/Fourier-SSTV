import processing.sound.*;


int res = 5;


void settings(){
  size(120*res, 160*res);
}


void setup(){
  
  background(255, 0, 0);
  noStroke();
  
  // Signal laden und analysieren
  s = new Signal("toneSignal.wav");
  
  // Bildpunkte zeichnen
  for (int i = 0; i < s.amplitudes.length; i++){
    fill(s.amplitudes[i] * 255);
    rect((i % 120) * res, floor(i / 120) * res, res, res);
  }
  
  //saveFrame("result.png");
}


void draw(){}
