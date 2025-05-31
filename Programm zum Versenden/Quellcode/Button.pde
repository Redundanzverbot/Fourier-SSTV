Button[] buttons = new Button[5];

float buttonWidth = 200;


class Button{
  
  int index;
  color c;
  float pos;
  int[] samples;
  float[] amplitudes;
  
  
  Button(int i, color col){
    c = col;
    index = i;
    pos = (i + 1) * 50 + i * buttonWidth;
  }
  
  
  Button(int i){
    index = i;
    pos = (i + 1) * 50 + i * buttonWidth;
  }
  
  
  boolean isPressed(int mx){
    return mx >= pos && mx <= pos + buttonWidth;
  }
  
  
  void show(){
    
    if (index == 0){
      stroke(255, 255, 255);
      strokeWeight(5);
      noFill();
      rect(pos, height - 200, buttonWidth, 210, 30, 30, 0, 0);
      
      fill(255);
      noStroke();
      textSize(100);
      textAlign(CENTER, CENTER);
      text("K", pos + buttonWidth * 0.5, height - 100);
    }
    
    else {
      fill(c);
      rect(pos, height - 200, buttonWidth, 200, 30, 30, 0, 0);
    }
    
    if (samples != null){
      stroke(0);
      strokeWeight(5);
      fill(255);
      circle(width - 250, pos + buttonWidth * 0.5, 35);
    }
  }
}
