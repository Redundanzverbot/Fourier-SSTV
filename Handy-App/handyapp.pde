import android.media.AudioRecord;
import android.media.AudioFormat;
import android.media.MediaRecorder;
import android.os.Environment;
import java.io.*;

AudioRecord recorder;

int bufferSize;
boolean isRecording = false;

int imgWidth = 160;
int imgHeight = 120;

Button recording;


void setup(){
  
  fullScreen();
  orientation(LANDSCAPE);
  
  requestPermission("android.permission.RECORD_AUDIO");
  
  bufferSize = AudioRecord.getMinBufferSize(44100, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT);
  recorder = new AudioRecord(MediaRecorder.AudioSource.MIC, 44100, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT, bufferSize);
  
  if (recorder.getState() != AudioRecord.STATE_INITIALIZED) {
    println("Fehlende Berechtigung zur Aufnahme");
    return;
  }
  
  // Buttons erstellen
  buttonHeight = (height - 6 * 30) / 5.0;
  
  buttons[0] = (new Button(0, color(255)));
  buttons[1] = (new Button(1, color(255)));
  buttons[2] = (new Button(2, color(255, 0, 0)));
  buttons[3] = (new Button(3, color(0, 255, 0)));
  buttons[4] = (new Button(4, color(0, 0, 255)));
  
  // Buttons anzeigen
  background(0);
  for (Button b : buttons){
    b.show();
  }
}


void draw(){
}


void mousePressed(){
  
  if (recording == null && mouseX > width - 200){
    
    for (int i = 0; i < 5; i++){
      if (buttons[i].isPressed(mouseY)){
        recording = buttons[i];
        startRecording();
      }
    }
  }
}


void showImage(){
  
  noStroke();
  
  // Bestimmen, welche Farbkanäle belegt sind
  int colorMode = 0;
  if (buttons[2].samples != null || buttons[3].samples != null || buttons[4].samples != null) colorMode = 1;
  else if (buttons[1].samples == null) return;
  boolean calibration = buttons[0].amplitudes != null;
  
  float deltaY = float(height) / imgHeight;
  
  // Alle Pixel anzeigen
  for (int i = 0; i < imgWidth * imgHeight; i++){
    
    // Graustufen
    if (colorMode == 0){
      
      float val = buttons[1].amplitudes[i];
      if (calibration) val /= buttons[0].amplitudes[i];
      
      fill(val * 255);
    }

    // Farbkanäle
    else{
      
      float[] c = new float[3];
      
      // Werte festlegen
      for (int j = 0; j < 3; j++){
        if (buttons[j + 2].amplitudes != null) c[j] = buttons[j + 2].amplitudes[i];
      }
      
      // Werte kalibrieren
      if (calibration){
        for (int j = 0; j < 3; j++){
          c[j] /= buttons[0].amplitudes[i];
        }
      }
      
      fill(c[0] * 255, c[1] * 255, c[2] * 255);
    }
    
    rect(deltaY * (i % imgWidth), deltaY * (floor(i / imgWidth)), deltaY, deltaY);
  }
}


// Aufnahme beginnen
void startRecording() {
  
  background(0);
  for (Button b : buttons){
    b.show();
  }
  
  // Auf einem zweiten Kern Tonspur aufnehmen
  recorder.startRecording();
  new Thread(new Runnable() {public void run() {collectAudioData();}}).start();
  
  isRecording = true;
}


// Aufnahme beenden
void stopRecording() {
  
  isRecording = false;
  if (recorder.getRecordingState() == AudioRecord.RECORDSTATE_RECORDING) {
    recorder.stop();
  }
  
  recording.processAudioData();
  recording = null;
  
  background(0);
  for (Button b : buttons){
    b.show();
  }
  
  showImage();
}


// Methode zum Aufnehmen, wird in einem zweiten Kern ausgeführt
void collectAudioData() {
  
  byte[] audioData = new byte[bufferSize];     // Liest die Rohdaten eines Durchgangs aus
  int[] recordSamples = new int[44100];        // Speichert die Aufnahme
  int counter = 0;                             // Zählt die Anzahl der gesammelten Samples
  int startTime = millis();

  while (isRecording) {
    
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
