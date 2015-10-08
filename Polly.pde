import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

import sojamo.drop.*;

Minim minim;
AudioInput in;
AudioOutput out;
AudioRecorder recorder;
AudioPlayback pb;
AudioRecorder take;
AudioOutput outo;
SDrop drop;

UI ui;
VisualCollection vc;

static String message = "Polly version 1";

static int ACTIONKEY = ' ';
static int ALTERNATEKEY = SHIFT;
static int CONTROLKEY = CONTROL;
static int VALUEKEY1 = LEFT;
static int VALUEKEY2 = RIGHT;
static int MODEKEY1 = UP;
static int MODEKEY2 = DOWN;
static int REMOVEKEY = BACKSPACE;

color bgRed = color (255, 0,0);
color bgGreen = color (0, 0, 0);
color bgBlue = color (0, 255,0);

color bgColor;

boolean endrecording = false;
boolean takerecording = false;

boolean isCONTROLKEY = false;
boolean isALTERNATEKEY = false;

boolean isENTER = false;

SoundSampleHandler sh;

int currentSoundSample = 0;

String title;

Stack stack;
int startRecordingDelay = 0;
int automaticRecodingLenght = 0;

int RecordingDelay_step=50;
int automaticRecodingLenght_step=50;

boolean delayRecoding = false;
boolean automaticRecoding = false;

String recpath = "./samples/";
String recname = "rec_";

int recmultipler = 1;

// Mode 0=Track, 1=Group, 2=Sample

//HashMap modesName {0 : "Track"}

int[] modes = {0,1,2};
int currentMode;

void setup()
{
  size(640,480, P3D);
  stack = new Stack();
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 1024);
  out = minim.getLineOut(Minim.STEREO, 1024);
  pb = new AudioPlayback();
  //in.addListener(pb);

  recorder = minim.createRecorder(in, recpath + "rec.wav", true);
  outo = minim.getLineOut(Minim.STEREO, 1024);
  outo.mute();
  currentMode=0;
  ui = new UI(this);
  vc = new VisualCollection();

  bgColor = bgGreen;

  sh = new SoundSampleHandler(this);

  drop = new SDrop(this);

  vc.put("message", message);
}

boolean inmute = false;
boolean outmute = false;
int backupStartRecordingMillis = 0;
int lastmillis = 0;
int recordingtime = 0;

int activeSoundSampleGroup = 0;

void draw()
{
  //if(isENTER)
  //{
  //  sh.soloCheck();
  // }
  //else {
  sh.groupCheck();
  //}
  background(bgColor);

  if(startRecordingDelay > 0 && delayRecoding)
  {
    startRecordingDelay -= (millis() - lastmillis);
    lastmillis = millis();
    //println(startRecordingDelay);
  }
  else if(delayRecoding && startRecordingDelay <= 0)
  {
    startRecordingDelay = 0;
    handleRecording();
    //println("bup: " + backupStartRecordingMillis);
    startRecordingDelay = backupStartRecordingMillis;
    delayRecoding = false;
  }

  if(recorder.isRecording())
  {
    recordingtime += (millis()-lastmillis);
    if(automaticRecoding)
    {
      vc.put("recordingtime", automaticRecodingLenght - recordingtime);
    }
    else {
      vc.put("recordingtime", recordingtime);
    }
    lastmillis = millis();
    if(automaticRecoding && recordingtime >= automaticRecodingLenght)
    {
      handleRecording();
    }
  }
  else
  {
    vc.put("recordingtime", startRecordingDelay);
  }

  vc.put("inleft", in.left.toArray());
  vc.put("inright", in.right.toArray());
  vc.put("outleft", outo.left.toArray());
  vc.put("outright", outo.right.toArray());

  vc.put("numactivesample", (sh.getActiveSoundSampleFalseInt()));
  vc.put("numsamples", sh.size());
  //text((sh.getActiveSoundSampleFalseInt()) + " / " + sh.size(), 10, 70);

  vc.put("control", this.isCONTROLKEY);
  vc.put("recording", recorder.isRecording());

  vc.put("recodingdelay", startRecordingDelay);
  vc.put("automaticRecodingLenght", automaticRecodingLenght);
  vc.put("activeSoundSampleGroup", activeSoundSampleGroup);
  vc.put("TakeRecording", takerecording);

  if(sh.size() != 0)
  {
    vc.put(sh.getActiveSoundSample());
  }

  ui.draw(vc);
}

void keyReleased()
{
  if (keyCode == this.CONTROLKEY) {
    //println("Ctrl is released");
    this.isCONTROLKEY = false;
  }
  else if (keyCode == this.ALTERNATEKEY) {
    //println("Alt is pressed");
    this.isALTERNATEKEY = false;
  }
  else if (keyCode == ENTER) {
    //println("Enter is pressed");
    sh.soloCurrentSoundSampleStop();
    if(takerecording)
    {
      outo.clearSignals();
      for(int i = 0; i < sh.size(); i++)
      {
        if(!sh.get(i).isMuted())
        {
          
          outo.addSignal(sh.get(i).GetAudioPlayback());
        }
      }
    }
    this.isENTER = false;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == this.VALUEKEY1) {
      if(this.isCONTROLKEY )
      {
        //if(inmute)
        //{
        //  in.addListener(pb);
        //  inmute = false;
        //}
        //else {
        //  in.removeListener(pb);
        //  inmute = true;
        //}
        sh.setActiveSampleBalance(-0.01);

      }
      else {
        sh.setActiveSoundSample(-1);
        sheckmuted();
      }
    }
    else if (keyCode == this.VALUEKEY2) {
      if(this.isCONTROLKEY )
      {
        //if(outmute)
        //{
        //  out.addSignal(pb);
        //  outmute = false;
        //}
        //else {
        //  out.removeSignal(pb);
        //  outmute = true;
        //}
        sh.setActiveSampleBalance(0.01);
        
      }
      else {
        sh.setActiveSoundSample(1);
        //println("fdkf");
        sheckmuted();
        //println("fdkf2");
      }
    }
    else if (keyCode == this.MODEKEY1) {
      if(this.isCONTROLKEY)
      {
         sh.setActiveSampleGain(1.0);
        //this.vc.put("mode", setMode(1));
        
        //println(this.vc.get("mode"));
      }
    }
    else if (keyCode == this.MODEKEY2) {
      if(this.isCONTROLKEY)
      {
        sh.setActiveSampleGain(-1.0);
        //this.vc.put("mode", setMode(-1));
        //println(this.vc.get("mode"));
      }
    }
    else if (keyCode == this.ALTERNATEKEY) {
      //println("Alt is pressed");

      this.isALTERNATEKEY = true;
    }
    else if (keyCode == this.CONTROLKEY) {
      //println("Ctrl is pressed");

      this.isCONTROLKEY = true;
    }
  }
  else if(key == 'e')
  {
    if(sh.size() != 0)
    {
      sh.SaveSoundSamples();
    }
  }
  else if(key == 't')
  {
    if(takerecording)
    {
      take.endRecord();
      take.save();

      outo.clearSignals();
      
      //println("Done saving take ");
      takerecording = false;
    }
    else 
    {
      String taketitle = "take" + millis() + ".wav";
      //println("Starting take to file: " + taketitle);
      //take = minim.AudioRecorder(out, recpath + taketitle);
      //AudioOutput outo = minim.getLineOut(Minim.STEREO, 2048,44100,16);
      //in.removeListener(pb);
      //println("print in:" + in.signalCount());
      //println("print out:" + out.signalCount());
      //println("print outo:" + outo.signalCount());
      outo.clearSignals();
      
      for(int i = 0; i < sh.size(); i++)
      {
        if(!sh.get(i).isMuted())
        {
          outo.addSignal(sh.get(i).GetAudioPlayback());
          //outo.addSignal(sh.get(i).GetAudioPlayer());
          //sh.get(i).GetAudioPlayback().mute();
        }
      }

      println("Signal count: " + outo.signalCount());

      take = minim.createRecorder(outo, recpath + taketitle, false);
      take.beginRecord();
      takerecording = true;
    }
  }
  else if(key == 'T')
  {
    if(takerecording && take.isRecording())
    {
      take.endRecord();
      outo.clearSignals();
      println("pause");
    }
    else if (takerecording && !take.isRecording())
    {
      println("start again");
      for(int i = 0; i < sh.size(); i++)
      {
        if(!sh.get(i).isMuted())
        {
          outo.addSignal(sh.get(i).GetAudioPlayback());
        }
      }
      take.beginRecord();
    }
  }
  else if(key == this.ACTIONKEY)
  {
    //println("ACTION");
    if(this.isCONTROLKEY )
    {
      handleMute();
    }
    else
    {
      handleRecording();
    }
  }
  else if (key == '1'||key == '2'||key == '3'||key == '4'||key == '5'||key == '6'||key == '7'||key == '8'||key == '9'||key == '0')
  {
    if(this.isCONTROLKEY)
    {

      //activeSoundSampleGroup = int(str(key));
      //println("setActiveSampleToOrder: " + int(str(key)));
      sh.setThisSampleOrder(int(str(key)));
      //println("activeSoundSampleGroup: " + activeSoundSampleGroup);
    }
    else {
      if (sh.getActiveSoundSample() != null)
      {
        //println ("Set sample to group: " + int(str(key)));
        sh.addActiveSoundSampleToGroup(int(str(key)));
      }
    }
  }
  

  else if(key == '+'||key == '?')
  {   
    if(!this.isALTERNATEKEY)
    {
      startRecordingDelay += RecordingDelay_step;
      //println("recodingdelay: " + startRecordingDelay);
    }
    else if(this.isALTERNATEKEY)
    {
      automaticRecodingLenght+=automaticRecodingLenght_step;
      //println("automaticRecodingLenght: " + automaticRecodingLenght);
    }
  }
  else if(key == '-'||key == '_')
  { 

    if(!this.isALTERNATEKEY)
    {   
      startRecordingDelay -= RecordingDelay_step;
      startRecordingDelay = constrain(startRecordingDelay, 0, startRecordingDelay);
      //println("recodingdelay: " + startRecordingDelay);
    }
    else if(this.isALTERNATEKEY)
    {
      automaticRecodingLenght -= automaticRecodingLenght_step;
      automaticRecodingLenght = constrain(automaticRecodingLenght, 0, automaticRecodingLenght);
      //println("automaticRecodingLenght: " + automaticRecodingLenght);
    }
  }
  else if(key == REMOVEKEY)
  {
    if (sh.getActiveSoundSample() != null)
    {
      if(takerecording)
      {
        outo.removeSignal(sh.getActiveSoundSample().GetAudioPlayback());
      }
      handelRemoveSoundSample();
    }
  }
  else if(key == ENTER && !isENTER)
  {
    if (sh.getActiveSoundSample() != null)
    {
      if(takerecording)
      {
        outo.clearSignals();
        outo.addSignal(sh.getActiveSoundSample().GetAudioPlayback());
      }
      isENTER = true;
      //handelRemoveSoundSample();
      sh.soloCurrentSoundSampleStart();
    }
  }
}


void handelRemoveSoundSample()
{
  sh.removeCurrentSoundSample();
}

void handleMute()
{
  if (sh.getActiveSoundSample() != null)
    if(!sh.getActiveSoundSample().isMuted())
    {
      //println(sh.getActiveSoundSample().isPlaying() + " " + sh.getActiveSoundSample().isLooping());
      if(takerecording)
      {
        outo.removeSignal(sh.getActiveSoundSample().GetAudioPlayback());
      }
      sh.getActiveSoundSample().mute();
      vc.put("status", "mute");
    }
    else {
      sh.getActiveSoundSample().unmute();
      if(takerecording)
      {
        outo.addSignal(sh.getActiveSoundSample().GetAudioPlayback());
      }
      vc.put("status", "playing");
    }
  sheckmuted();
}

void handleRecording()
{
  if(recorder.isRecording() && !endrecording)
  {
    recorder.endRecord();
    bgColor = bgGreen;
    endrecording = false;
    sh.loadAudioPlayer(recorder.save());
    sh.addActiveSoundSampleToGroup(activeSoundSampleGroup);
    delayRecoding = false;

    automaticRecoding = false;
    sh.setLastSoundSampleToActive();
  }
  else {
    if(startRecordingDelay <= 0)
    {
      title = "rec" + millis() + ".wav";
      //title = recname + recmultipler + ".wav";
      recorder = minim.createRecorder(in, recpath+title, false);
      recorder.beginRecord();
      bgColor = bgRed;
      endrecording = false;
      recordingtime = 0;
      lastmillis = millis();
      recmultipler++;
      if(automaticRecodingLenght > 0)
      {
        automaticRecoding = true;
      }
    }
    else
    {
      backupStartRecordingMillis = startRecordingDelay;

      delayRecoding = true;
      lastmillis = millis();
    }
  }
}

void sheckmuted()
{
  if(sh.size() > 0)
  {
  if(sh.getActiveSoundSample().isMuted())
  {
    bgColor = bgBlue;
  }
  else
  {
    bgColor = bgGreen;
  }
  }
}

void dropEvent(DropEvent theDropEvent)
{
  if(theDropEvent.isFile())
  {
    String[] m1 = match(theDropEvent.file().getAbsolutePath(), ".wav");
    if (m1 != null) {
      sh.loadWAV(theDropEvent.file().getAbsolutePath(), activeSoundSampleGroup);
      return;
    }
    m1 = match(theDropEvent.file().getAbsolutePath(), ".mp3");
    if (m1 != null) {
      sh.loadWAV(theDropEvent.file().getAbsolutePath(), activeSoundSampleGroup);
      return;
    }
    m1 = match(theDropEvent.file().getAbsolutePath(), ".xml");
    if (m1 != null) {
      sh.loadXML(theDropEvent.file().getAbsolutePath());
    }
  }
}

int setMode(int value)
{
    if(modes.length > 0)
    {
      if(value > 0)
      {
        if(currentMode + value > modes.length-1) {
          currentMode = 0;
        }
        else {
          currentMode += value;
        }
      }
      else {
        if(currentMode + value < 0){
          currentMode = modes.length-1;

        }
        else {
          currentMode = currentMode + value;

        }
      }
    }
    println("mode: " + currentMode);
    return currentMode;
}

void stop()
{
  sh.CloseSoundSamples();
  out.close();
  in.close();
  minim.stop();
  super.stop();
}




















