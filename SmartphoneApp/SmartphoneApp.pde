import android.media.AudioRecord;
import android.media.AudioFormat;
import android.media.MediaRecorder;
import android.os.Environment;
import java.io.*;

AudioRecord recorder;

int bufferSize;
boolean isRecording = false;

int imgWidth = 120;
int imgHeight = 160;
int res;


void setup(){
  
  fullScreen();
  orientation(PORTRAIT);
  
  // App benötigt Zugriff auf das Mikrofon
  requestPermission("android.permission.RECORD_AUDIO");
  
  bufferSize = AudioRecord.getMinBufferSize(44100, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT);
  recorder = new AudioRecord(MediaRecorder.AudioSource.MIC, 44100, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT, bufferSize);
  
  // Buttons erstellen
  res = width / imgWidth;
  bWidth = (width - 6 * 30) / 5;
  
  buttons[0] = (new Button(0, color(255, 255, 255)));
  buttons[1] = (new Button(1, color(255, 255, 255)));
  buttons[2] = (new Button(2, color(255,   0,   0)));
  buttons[3] = (new Button(3, color(  0, 255,   0)));
  buttons[4] = (new Button(4, color(  0,   0, 255)));
  
  // Buttons anzeigen
  background(0);
  noStroke();
  fill(255);
  rect(0, 0, width, res*imgHeight);
  textSize(80);
  textAlign(CENTER, CENTER);
  for (Button b : buttons) b.show();
}


void draw(){}


void mousePressed(){
  
  if (recording != null || mouseY < height-bHeight) return;
  
  // Teste, ob ein Button gedrückt wurde
  for (int i = 0; i < 5; i++){
    if (!buttons[i].isPressed(mouseX)) continue;
    
    recording = buttons[i];
    startRecording();
    break;
  }
}


void showImage(){
  
  noStroke();
  
  // Bestimme den Farbmodus
  int colorMode = 0;
  if (buttons[2].samples != null || buttons[3].samples != null || buttons[4].samples != null) colorMode = 1;
  else if (buttons[0].samples == null && buttons[1].samples == null) return;
  
  // Speichere, ob kalibriert wurde
  boolean calibration = buttons[0].amplitudes != null;
  
  // Zeige alle Pixel an
  for (int i = 0; i < imgWidth * imgHeight; i++){
    
    // Graustufen
    if (colorMode == 0){
      float val = buttons[1].samples == null ? buttons[0].amplitudes[i]
                                             : calibration ? buttons[1].amplitudes[i] / buttons[0].amplitudes[i]
                                                           : buttons[1].amplitudes[i];
      fill(val*255);
    }

    // In Farbe
    else {
      float[] c = new float[3];
      
      // Werte festlegen
      for (int j = 0; j < 3; j++){
        if (buttons[j + 2].amplitudes == null) continue;
          c[j] = calibration ? buttons[j + 2].amplitudes[i] / buttons[0].amplitudes[i]
                             : buttons[j + 2].amplitudes[i];
      }
      
      fill(c[0]*255, c[1]*255, c[2]*255);
    }
    
    rect(res * (i % imgWidth), res * (floor(i / imgWidth)), res, res);
  }
}


// Aufnahme beginnen
void startRecording() {
  
  background(0);
  fill(255);
  rect(0, 0, width, res*imgHeight);
  for (Button b : buttons) b.show();
  
  if (recorder.getState() != AudioRecord.STATE_INITIALIZED) {
    text("Fehlende Berechtigung", .5*width, height - 600);
    recording = null;
    return;
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
  fill(255);
  rect(0, 0, width, res*imgHeight);
  for (Button b : buttons) b.show();
  
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
