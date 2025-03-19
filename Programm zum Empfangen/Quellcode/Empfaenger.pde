import processing.sound.*;

Signal s;


void setup(){
  
  size(160*7, 120*7);
  background(255, 0, 0);
  noStroke();
  
  // Signal laden und analysieren
  s = new Signal("toneSignal.wav");
  
  // Bildpunkte zeichnen
  for (int i = 0; i < s.amplitudes.length; i++){
    fill(s.amplitudes[i] * 255);
    rect((i % 160) * 7, floor(i / 160) * 7, 7, 7);
  }
  
  saveFrame("result.png");
}


void draw(){
}
