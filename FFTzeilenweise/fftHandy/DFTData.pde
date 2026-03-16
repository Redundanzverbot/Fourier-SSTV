// Methode zum Aufnehmen der DFT-Daten, wird in einem zweiten Kern ausgeführt


void collectDFTData() {
  
  byte[] audioData = new byte[bufferSize];     // Liest die Rohdaten eines Durchgangs aus
  int[] recordSamples = new int[44100];        // Speichert die Aufnahme
  int counter = 0;                             // Zählt die Anzahl der gesammelten Samples
  int startTime = millis();

  while (isRecording == 1) {
    
    // Rohdaten auslesen
    int read = recorder.read(audioData, 0, bufferSize);
    
    // Überspringen, falls keine Daten vorhanden. Außerdem werden 500 ms gewartet, um Interferenzen zu verringern
    if (read == 0 || millis() - startTime < 500){
      continue;
    }
    
    // Konvertiere Rohdaten in Ganzzahlen (2-Byte LE)
    int[] samples = new int[audioData.length / 2];

    for (int i = 0; i < audioData.length; i+=2){
      int b1 = audioData[i];
      int b2 = audioData[i + 1] * int(pow(2, 8));
      samples[i / 2] = b1 + b2;
    }
    
    for (int i = 0; i < samples.length; i++){
      
      // Beenden, sobald alle Samples gesammelt wurden
      if (counter >= recordSamples.length){
        recording.samples = recordSamples;
        stopRecording();
        return;
      }
      
      // Hinzufügen eines Samples
      recordSamples[counter] = samples[i];
      counter++;
    }
  }
}
