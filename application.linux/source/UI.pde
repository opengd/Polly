class UI
{
  private PApplet _parent;
  PFont font;
  public UI(PApplet parent)
  {
    _parent = parent;
    font = loadFont("Impact-70.vlw");
    textFont(font, 70);  
  }

  public void draw(VisualCollection vc)
  {
    textFont(font, 15);
    text(vc.get("message").toString(), 10, 20);
    
    int ac = height/2;
    stroke(255, 255, 255);
    drawLineVisualization((float[])vc.get("inleft"), 50, 50+ac, width/4, (width/4)*3);
    drawLineVisualization((float[])vc.get("inright"), 50, 53+ac,  width/4, (width/4)*3);

    //stroke(123, 0, 0);
    drawLineVisualization((float[])vc.get("outleft"), 50, 56+ac,  width/4, (width/4)*3);
    drawLineVisualization((float[])vc.get("outright"), 50, 59+ac,  width/4, (width/4)*3);

    if(sh.size() > 0)
    {
      //stroke(72, 0, 0);
      drawLineVisualization((float[])vc.get("sampleft"), 50, 62+ac, width/4, (width/4)*3);
      drawLineVisualization((float[])vc.get("sampright"), 50, 65+ac,  width/4, (width/4)*3);

      stroke(255);
      textFont(font, 25);
      text("Filename: " + vc.get("filename").toString(), (width/10), (height/10));
      text("Lenght: " + vc.get("length").toString(), (width/4)*2.5, (height/10));
      text("Postion: " + vc.get("position").toString(), (width/10), (height/3)*1.2);
      text("Group: " + vc.get("samplegroup").toString(), (width/10), (height/3)*2.2);
      text("Order: " + vc.get("sampleorder").toString(), (width/10), (height/3)*2.35);
     
      //text(vc.get("status").toString(), 100, 185);
      //println(vc.get("StartRecordingMilli").toString() + "kfkfkf");
      //println("statans");
      //Stack h = new Stack();
      //h.pop();
    }
    stroke(255);
    textFont(font, 70);
    text(vc.get("numactivesample").toString() + " / " + vc.get("numsamples").toString(), width/2, height/2);
    textFont(font, 25);
    text("ControlKey: " + vc.get("control").toString(), (width/10), 125);
    text("Recording: " + vc.get("recording").toString(), (width/10), 155);
    text("Recordingtime: " + vc.get("recordingtime").toString(), (width/10), (height/3)*1.5);
    text("ActiveSoundSampleGroup: " + vc.get("activeSoundSampleGroup").toString(), (width/10), (height/3)*1.7);
    text("Auto Recordingtime: " + vc.get("automaticRecodingLenght").toString(), (width/10), (height/3)*2.5);
    text("Recordingdelay: " + vc.get("recodingdelay").toString(), (width/10), (height/3)*2.7);
    text("TakeRecording: " + vc.get("TakeRecording").toString(), (width/10), (height/3)*2.9);
  }

  private void drawLineVisualization(float[] linearray, int arrayscale, int y1)
  {
    for(int i = 0; i < linearray.length - 1; i++)
    {
      line(i, y1 + linearray[i]*arrayscale, i+1, y1 + linearray[i+1]*arrayscale);
    }
  }
  private void drawLineVisualization(float[] linearray, int arrayscale, int y1, int x1, int x2)
  {
    for(int i = x1; i < x2 - 1; i++)
    {
      line(i, y1 + linearray[i]*arrayscale, i+1, y1 + linearray[i+1]*arrayscale);
    }
  }
  
  private void drawCircleVisualization(float[] floatarray, int arrayscale, int y1, int y2)
  {

    int nubofdots = 360 / (floatarray.length - 1);

    for(int i = 0; i < floatarray.length - 1; i++)
    {
      //linearray[i]*arrayscale  
      //line(_parent.width/2, _parent.height/2,  
    } 
  }

}















