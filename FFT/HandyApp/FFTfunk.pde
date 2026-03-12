// Rekonstruieren des Bilds aus dem Tongemisch


import android.media.AudioRecord;
import android.media.AudioFormat;
import android.media.MediaRecorder;
import android.os.Environment;
import java.io.*;

AudioRecord recorder;

int bufferSize;
int isRecording = 0; // 0: nicht, 1: DFT, 2: FFT
int mode = 0;        //           0: DFT, 1: FFT

int[] imgWidth = {120, 105};
int[] imgHeight = {160, 140};

float res;


void setup(){
  
  fullScreen();
  orientation(PORTRAIT);
  
  // App benötigt Zugriff auf das Mikrofon
  requestPermission("android.permission.RECORD_AUDIO");
  
  bufferSize = AudioRecord.getMinBufferSize(44100, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT);
  recorder = new AudioRecord(MediaRecorder.AudioSource.MIC, 44100, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT, bufferSize);
  
  // Buttons erstellen
  bWidth = (width - 6 * 30) / 5;
  res = float(width) / imgWidth[mode];
  
  buttons[0] = (new Button(0, color(255, 255, 255)));
  buttons[1] = (new Button(1, color(255, 255, 255)));
  buttons[2] = (new Button(2, color(255,   0,   0)));
  buttons[3] = (new Button(3, color(  0, 255,   0)));
  buttons[4] = (new Button(4, color(  0,   0, 255)));
}


void draw(){
  
  // Beim Laden der DFT darf nicht aktualisiert werden
  if (recording != null) return;

  // Hintergrund
  background(0);
  noStroke();
  fill(255);
  rect(0, 0, width, res*imgHeight[mode]);
  
  // DFT / FFT
  fill(255);
  textSize(80);
  textAlign(RIGHT, CENTER);
  text(mode == 0 ? "DFT" : "FFT", width-50, res*imgHeight[mode] + 100);
  
  if (isRecording == 0){
    textSize(80);
    textAlign(CENTER, CENTER);
    for (Button b : buttons) b.show();
    showImage();
  }
  
  // FFT anzeigen
  else if (isRecording == 2){
    
    int time = millis();
    
    float[] fftSpectrum = magnitudes(fft(toImaginary(fftSamples)));
    
    println(fftSpectrum[1]);
    
    for (int y = 0; y < imgHeight[mode]; y++){
      for (int x = 0; x < imgWidth[mode]; x++){
        fill((fftSpectrum[x + y*imgWidth[mode] + 2] / fftSpectrum[1]) * 255);
        rect(x * res, y * res, res, res);
      }
    }
    
    
    println(millis() - time);
  }
}


void mousePressed(){
  
  // DFT darf nicht gestört werden, Bild erwartet keinen Klick
  if (recording != null || mouseY < res*imgHeight[mode]) return;
  
  // FFT -> DFT
  if (isRecording == 2){
    stopRecording();
    mode = 0;
    res = float(width) / imgWidth[mode];
  }
  
  // DFT -> FFT
  else if (mouseY < height-bHeight){
    mode = 1;
    startRecording();
    res = float(width) / imgWidth[mode];
  }
  
  // Button gedrückt
  else {
    for (int i = 0; i < 5; i++){
      if (!buttons[i].isPressed(mouseX)) continue;
      
      if (mode == 0) recording = buttons[i];
      startRecording();
      
      for (Button b : buttons) b.show();
    
      break;
    }
  }
}


void showImage(){
  
  // Bestimme den Farbmodus
  int colorMode = 0;
  if (buttons[2].samples != null || buttons[3].samples != null || buttons[4].samples != null) colorMode = 1;
  else if (buttons[0].samples == null && buttons[1].samples == null) return;
  
  // Speichere, ob kalibriert wurde
  boolean calibration = buttons[0].amplitudes != null;
  
  // Zeige alle Pixel an
  for (int i = 0; i < imgWidth[mode] * imgHeight[mode]; i++){
    
    // Graustufen
    if (colorMode == 0){
      float val = buttons[1].samples == null ? buttons[0].amplitudes[i]
                                             : calibration ? buttons[1].amplitudes[i] / buttons[0].amplitudes[i]
                                                           : buttons[1].amplitudes[i];
      fill(val*255);
      //fill(val > 0.5 ? 255 : 0);
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
    
    rect(res * (i % imgWidth[mode]), res * (floor(i / imgWidth[mode])), res, res);
  }
}


// Aufnahme beginnen
void startRecording() {
  
  if (recorder.getState() != AudioRecord.STATE_INITIALIZED) {
    text("Fehlende Berechtigung", .5*width, height - 600);
    recording = null;
    return;
  }
  
  // Auf einem zweiten Kern Tonspur aufnehmen
  recorder.startRecording();
  if (mode == 0) new Thread(new Runnable() {public void run() {collectDFTData();}}).start();
  else new Thread(new Runnable() {public void run() {collectFFTData();}}).start();
  
  isRecording = mode + 1;
}


// Aufnahme beenden
void stopRecording() {
  
  isRecording = 0;
  if (recorder.getRecordingState() == AudioRecord.RECORDSTATE_RECORDING) recorder.stop();
  
  if (mode == 0) recording.processAudioData();
  recording = null;
}
