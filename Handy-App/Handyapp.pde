import android.media.AudioRecord;
import android.media.AudioFormat;
import android.media.MediaRecorder;
import android.os.Environment;
import java.io.*;

AudioRecord recorder;

int bufferSize;
boolean isRecording = false;
boolean calibrating = false;

Signal s;

int imgWidth = 160;
int imgHeight = 120;

float[] calibration = new float[imgWidth*imgHeight];


void setup(){
  
  fullScreen();
  
  requestPermission("android.permission.RECORD_AUDIO");
  
  bufferSize = AudioRecord.getMinBufferSize(44100, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT);
  recorder = new AudioRecord(MediaRecorder.AudioSource.MIC, 44100, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT, bufferSize);
  
  if (recorder.getState() != AudioRecord.STATE_INITIALIZED) {
    println("Fehlende Berechtigung zur Aufnahme");
    return;
  }
  
  background(0);
  noStroke();
  
  fill(255, 0, 0);
  rect(0, height - 200, 200, 200, 0, 50, 0, 0);
  
  fill(255, 255, 255);
  rect(300, height - 200, 200, 200, 50, 50, 0, 0);
}


void draw(){
  
  if (mousePressed && mouseY < height - 200 && mouseX < 200){
    mult = (float) mouseY / (height - 200.0) * 2.0;
    println(mult);
    s.showImage();
  }
}


void mousePressed(){
  
  if (!isRecording && mouseY > height - 200){
    if (mouseX < 200) {
      startRecording();
    } else if (mouseX > 300 && mouseX < 500){
      calibrating = true;
      println("KNOPF ZUR KALIBRIERUNG GEDRÜCKT");
      startRecording();
    }
  }
}


// Aufnahme beginnen
void startRecording() {
  
  // Auf einem zweiten Kern Tonspur aufnehmen
  recorder.startRecording();
  new Thread(new Runnable() {public void run() {processAudioData();}}).start();
  
  isRecording = true;
}


// Aufnahme beenden
void stopRecording() {
  
  isRecording = false;
  if (recorder.getRecordingState() == AudioRecord.RECORDSTATE_RECORDING) {
    recorder.stop();
  }
}


// Methode zum Aufnehmen, wird in einem zweiten Kern ausgeführt
void processAudioData() {
  
  byte[] audioData = new byte[bufferSize]; // Liest die Rohdaten eines Durchgangs aus
  int[] recording = new int[44100];        // Speichert die Aufnahme
  int counter = 0;                         // Zählt die Anzahl der gesammelten Samples
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
      if (counter >= recording.length){
        stopRecording();
        if (calibrating){
          s = new Signal(recording);
        }
        else if (s != null){
          s.samples = recording;
          s.readFrequencies();
        }
        return;
      }
      
      // Hinzufügen eines Samples
      recording[counter] = samples[i];
      counter++;
    }
  }
}
