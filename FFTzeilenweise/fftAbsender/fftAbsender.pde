// Generieren des Tongemischs zum ausgewählten Bild


import processing.sound.*;

PImage image;
int progress = 0;
float thresh = 0.5;
int mode = 0;
int bL = 0;
int[] blockLength = {44100, 32768};
int repAmt = 1;


void settings(){
  size(480, 640);
}


void setup(){}


void draw(){
  
  if (image == null){
    background(255);
    fill(180);
    textAlign(CENTER, CENTER);
    textSize(50);
    text("Datei auswählen", width / 2, height / 6);
    text(mode == 0 ? "Graustufen" : mode == 1 ? "Schwarz-weiß" : mode == 2 ? "Rot" : mode == 3 ? "Grün" : "Blau", width / 2, 3 * height / 6);
    text("Blocklänge: " + blockLength[bL], width / 2, 5 * height / 6);
  }
  
  else {
    float res = float(width) / image.width;
    noStroke();
    for (int y = 0; y < progress; y++){
      for (int x = 0; x < image.width; x++){
        fill(getCol(x, y));
        rect(x*res, y*res, res, res);
      }
    }
    stroke(0);
    line(0, progress*res, width, progress*res);
  }
}


void fileSelected(File selection) {
  
  if (selection == null) return;
  
  image = loadImage(selection.getAbsolutePath());
  
  // Skaliere das Bild auf eine Größe, die an die Blocklänge angepasst ist
  switch (bL){
    
    case 0:
    image.resize(120, 160); // 44100/2 > 120*160
    break;
    
    case 1:
    image.resize(105, 140); // 32768/2 > 105*140
    break;
  }
  
  thread("loadSignal");
}


void mousePressed(){
  
  if (image != null) return;
  
  if (mouseY < height / 3) selectInput("Bilddatei auswählen", "fileSelected");
  else if (mouseY < 2*height / 3) mode = (mode + 1) % 5;
  else bL = (bL+1) % 2;
}


void loadSignal(){
  
  s = new Signal(image, mode);
  saveBytes("toneSignal.wav", s.exportWav());
  s.updateSample(this);
  s.sample.loop();
  println("SIGNAL DONE");
}


// Setzt ein Tongemisch nach den gegebenen Parametern zusammen
float[] inverseFourier(int[] amplitudes){
  
  // Das Ergebnis hat die entsprechende Blocklänge
  float[] result = new float[blockLength[bL] * repAmt];
  
  // Generiere alle Töne
  for (int f = 0; f < amplitudes.length; f++){
    
    progress = floor(f / (image.width+1));
    if (amplitudes[f] == 0) continue;
    
    // Generiere einen zufälligen Phasenwinkel, um Interferenzen zu minimieren
    float phi = random(TAU);
    
    // Taste die Sinuswelle ab: Es werden in dem Block n Perioden durchlaufen 
    for (int s = 0; s < blockLength[bL]; s++){
      for (int r = 0; r < repAmt; r++){
        result[s + r*blockLength[bL]] += amplitudes[f] * sin((s * (f+1) * TAU) / blockLength[bL] + phi);
      }
    }
  }
  
  // Anpassen der Lautstärke durch Skalieren
  result = normalizeWave(result);
  
  return result;
}


// "Normalisiert" den Wertebereich einer Frequenzsumme auf das Intervall [-1;1]
float[] normalizeWave(float[] samples){
  
  float maxVal = 0;
  
  // Größten Ausschlag ermitteln
  for (float f : samples) maxVal = max(abs(f), maxVal);
  
  // Alle Daten als Anteil daran ausrichten
  for (int i = 0; i < samples.length; i++) samples[i] /= maxVal;
  
  return samples;
}


color getCol(int x, int y){
  
  switch(mode){
    case 0:
    return color(brightness(image.pixels[x + image.width*y]));
    
    case 1:
    return color(brightness(image.pixels[x + image.width*y]) / 255.0 > thresh ? 255 : 0);
    
    case 2:
    return color(red(image.pixels[x + image.width*y]), 0, 0);
    
    case 3:
    return color(0, green(image.pixels[x + image.width*y]), 0);
    
    case 4:
    return color(0, 0, blue(image.pixels[x + image.width*y]));
  }
  
  return color(128);
}
