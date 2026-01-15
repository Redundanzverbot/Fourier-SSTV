import processing.sound.*;


PImage image;


void setup(){
  size(400, 400);
  selectInput("Bilddatei auswählen", "fileSelected");
}


void draw(){}


void fileSelected(File selection) {
  
  if (selection != null){
    image = loadImage(selection.getAbsolutePath());
    s = new Signal(image, 0);
    saveBytes("toneSignal.wav", s.exportWav());
    s.updateSample(this);
    println("DONE");
    s.sample.loop();
  }
  else exit();
}


// Setzt ein Tongemisch nach den gegebenen Parametern zusammen
float[] inverseFourier(int[] amplitudes, int sampleRate){
  
  float[] result = new float[sampleRate];
  
  // Generiere alle Töne
  for (int f = 0; f < amplitudes.length; f++){
    
    // Generiere einen zufälligen Phasenwinkel
    float phi = random(TAU);
    
    // Taste die Sinuswelle ab
    for (int s = 0; s < sampleRate; s++){
      result[s] += amplitudes[f] * sin((s * (f+1) * TAU) / sampleRate + phi);
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
