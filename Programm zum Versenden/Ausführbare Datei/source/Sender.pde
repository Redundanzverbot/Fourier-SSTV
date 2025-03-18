import processing.sound.*;


void setup(){
  
  fullScreen();
  
  background(0);
  textAlign(CENTER);
  textSize(80);
  fill(255);
  text("Generierung des Tongemischs...", width / 2, 700);
  text("Wichtig: Zunächst geringe Lautstärke einstellen!", width / 2, 900);
  
  PImage img = loadImage("image.png");
  //img.resize(160, 120);
  imageMode(CENTER);
  image(img, width / 2, 320, 3*160, 3*120);
}


void draw(){
  
  if (s == null){
    
    // Geräusch laden
    s = new Signal("image.png");
    
    // Geräusch abspielen
    s.updateSample(this);
    s.sample.loop();
    
    // Speichern der .wav-Datei
    saveBytes("toneSignal.wav", s.exportWav());
    
    // Anzeigen einer Audiowelle
    s.show();
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


void mouseWheel(MouseEvent event) {
  zoom += event.getCount();
  zoom = max(1, zoom);
  s.show();
}
