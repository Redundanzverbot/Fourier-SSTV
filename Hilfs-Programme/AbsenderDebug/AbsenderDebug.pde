int blockLength = 32768;
int repAmt = 1;

void setup(){
  
  size(1500, 800);
  background(0);
  
  // Zeichne Blöcke
  stroke(180);
  for (int i = 1; i < repAmt; i++) line(i * float(width) / repAmt, 0, i * float(width) / repAmt, height);
  
  // Zeichne Audiowelle
  stroke(255);
  translate(0, height/2);
  float[] waveForm = inverseFourier();
  float deltaX = float(width) / (blockLength * repAmt);
  for (int i = 0; i < waveForm.length-1; i++) line(i * deltaX, 300 * waveForm[i], (i+1) * deltaX, 300 * waveForm[i+1]);
}



// Setzt ein Tongemisch nach den gegebenen Parametern zusammen
float[] inverseFourier(){
  
  // Das Ergebnis hat die entsprechende Blocklänge
  float[] result = new float[blockLength * repAmt];
  
  // Generiere alle Töne
  int f = 1;
  
  // Generiere einen zufälligen Phasenwinkel, um Interferenzen zu minimieren
  float phi = HALF_PI;
  
  // Taste die Sinuswelle ab: Es werden in dem Block n Perioden durchlaufen 
  for (int s = 0; s < blockLength; s++){
    for (int r = 0; r < repAmt; r++){
      result[s + r*blockLength] += sin((s * f * TAU) / blockLength + phi);
    }
  }
  
  return result;
}
