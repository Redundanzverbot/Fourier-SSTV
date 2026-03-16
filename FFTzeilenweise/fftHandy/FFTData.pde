// Methode zum Aufnehmen der FFT-Daten, wird in einem zweiten Kern ausgeführt


volatile float[] fftSamples = new float[32768];


void collectFFTData() {
  
  byte[] audioData = new byte[bufferSize];     // Liest die Rohdaten des Mikrofons aus

  while (isRecording == 2) {
    
    // Rohdaten auslesen
    int read = recorder.read(audioData, 0, bufferSize);
    
    // Überspringen, falls keine Daten vorhanden
    if (read == 0) continue;
    
    // Konvertiere Rohdaten in Ganzzahlen (2-Byte LE)
    int[] samples = new int[audioData.length / 2];

    for (int i = 0; i < audioData.length; i+=2){
      int b1 = audioData[i];
      int b2 = audioData[i + 1] * int(pow(2, 8));
      samples[i / 2] = b1 + b2;
    }
    
    // Speichere die Anzahl an Samples, die bestehen bleiben
    int keepLength = fftSamples.length - samples.length;
    
    // Verschiebe die Samples nach links, um die neuen anhängen zu können
    for (int i = 0; i < keepLength; i++) fftSamples[i] = fftSamples[i + samples.length];
    
    // Hänge die neuen Samples an
    for (int i = keepLength; i < fftSamples.length; i++) fftSamples[i] = samples[i-keepLength] * 1e-6;
  }
}
