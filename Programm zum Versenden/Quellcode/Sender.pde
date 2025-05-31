import processing.sound.*;

PImage img;
Signal sig;

float deltaX;

int imgWidth = 160;
int imgHeight = 120;

boolean playing = true;


void setup(){
  
  size(1600, 900);
  
  background(0);
  
  deltaX = (width * 0.5 - 75) / imgWidth;
  
  buttons[0] = (new Button(0));
  buttons[1] = (new Button(1, color(0)));
  buttons[2] = (new Button(2, color(255, 0, 0)));
  buttons[3] = (new Button(3, color(0, 255, 0)));
  buttons[4] = (new Button(4, color(0, 0, 255)));
  
  // Geräusch laden
  //s = new Signal("image.png");
  
  // Geräusch abspielen
  //s.updateSample(this);
  //s.sample.loop();
  
  // Speichern der .wav-Datei
  //saveBytes("toneSignal.wav", s.exportWav());
  
  // Anzeigen einer Audiowelle
  //s.show();
}


void draw(){

  background(200);
  textAlign(CENTER, CENTER);
  textSize(60);
  noStroke();
  
  buttons[0].show();
  
  // Bild-Kästchen
  fill(255);
  rect(50, 50, width / 2.0 - 75, 120 * deltaX);
    
  if (img != null){
    image(img, 80, 80, width / 2.0 - 135, imgHeight * deltaX - 60);
    for (int i = 1; i < 5; i++){
      buttons[i].show();
    }
  }
  
  else {
    fill(200);
    text("Select", 50 + (width / 2.0 - 75) * 0.5, 50 + imgHeight * 0.5 * deltaX);
  }
  
  // Wellen-Kästchen
  fill(255);
  rect(width / 2.0 + 25, 50, width / 2.0 - 75, imgHeight * deltaX);
  stroke(200);
  strokeWeight(3);
  
  line(width / 2.0 + 25, 50 + imgHeight * 0.5 * deltaX, width - 50, 50 + imgHeight * 0.5 * deltaX);
  if (sig != null){
    sig.show();
  }
  
  noStroke();
  fill(255);
  if (sig != null){
    if (playing){
      rect(width - 200, height - 200, 150, 150);
    } else {
      triangle(width - 200, height - 200, width - 50, height - 125, width - 200, height - 50);
    }
  }
}


void mousePressed(){
  
  if (mouseX >= 50 && mouseY >= 50 && mouseX <= width * 0.5 - 25 && mouseY <= 50 + imgHeight * deltaX){
    selectInput("Bilddatei auswählen", "fileSelected");
  }
  
  if (mouseY < height - 200){
    return;
  }
  
  if (dist(mouseX, mouseY, width - 100, height - 100) <= 150){
    if (playing) sig.sample.stop();
    else sig.sample.loop();
    playing = !playing;
  }
  
  // Kalibrierung
  if (buttons[0].isPressed(mouseX)){
    if (sig != null) sig.sample.stop();
    sig = new Signal(loadImage("white.png"), 0);
    sig.updateSample(this);
    sig.sample.loop();
    playing = true;
    saveBytes("toneSignal.wav", sig.exportWav());
    return;
  }
  
  // Farbkanal
  if (img == null){
    return;
  }
  
  for (int i = 1; i < 5; i++){
    if (buttons[i].isPressed(mouseX)){
      if (sig != null) sig.sample.stop();
      sig = new Signal(img, i - 1);
      sig.updateSample(this);
      sig.sample.loop();
      playing = true;
      saveBytes("toneSignal.wav", sig.exportWav());
      return;
    }
  }
}


void fileSelected(File selection) {
  
  if (selection != null){
    img = loadImage(selection.getAbsolutePath());
  }
}


// iDFT eines Tongemischs
float[] inverseFourier(int[] frequencies, int[] amplitudes, int sampleRate){
  
  float[] result = new float[sampleRate];
  
  // Generiere alle Töne
  for (int f = 0; f < frequencies.length; f++){
  
  // Addiere alle Töne zusammen
  float[] freq = generateSequence(frequencies[f], amplitudes[f], sampleRate);
    for (int i = 0; i < sampleRate; i++){
      result[i] += freq[i];
    }
  }
  
  // Anpassen der Lautstärke durch gemeinsamen Skalieren
  result = normalizeWave(result);
  
  return result;
}


// Beschränkt den Zahlenbereich einer Frequenzsumme auf das Intervall [-1.0;1.0]
float[] normalizeWave(float[] samples){
  
  float max = 0;
  
  for (float f : samples){
    if (abs(f) > max){
      max = abs(f);
    }
  }
  
  for (int i = 0; i < samples.length; i++){
    samples[i] = samples[i] / max;
  }
  
  return samples;
}


// iDFT eines einzelnen Tons
float[] generateSequence(int f, int a, int N){
  
  float[] result = new float[N];
  float phi = random(TAU);

  // Generiert eine Sinuswelle mit bestimmter Frequenz
  for (int t = 0; t < N; t++){
    result[t] = a * sin((t * f * TAU) / N + phi);
  }

  return result;
}
