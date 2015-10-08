import processing.core.*; 
import processing.xml.*; 

import ddf.minim.signals.*; 
import ddf.minim.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import sojamo.drop.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class Polly extends PApplet {








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

int bgRed = color (255, 0,0);
int bgGreen = color (0, 0, 0);
int bgBlue = color (0, 255,0);

int bgColor;

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

public void setup()
{
  size(640,480, P3D);
  stack = new Stack();
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 1024);
  out = minim.getLineOut(Minim.STEREO, 1024);
  pb = new AudioPlayback();
  in.addListener(pb);

  recorder = minim.createRecorder(in, recpath + "rec.wav", true);
  outo = minim.getLineOut(Minim.STEREO, 1024);

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

public void draw()
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
    println(startRecordingDelay);
  }
  else if(delayRecoding && startRecordingDelay <= 0)
  {
    startRecordingDelay = 0;
    handleRecording();
    println("bup: " + backupStartRecordingMillis);
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
  vc.put("outleft", out.left.toArray());
  vc.put("outright", out.right.toArray());

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

public void keyReleased()
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

public void keyPressed() {
  if (key == CODED) {
    if (keyCode == this.VALUEKEY1) {
      if(this.isCONTROLKEY )
      {
        if(inmute)
        {
          in.addListener(pb);
          inmute = false;
        }
        else {
          in.removeListener(pb);
          inmute = true;
        }
      }
      else {
        sh.setActiveSoundSample(-1);
        sheckmuted();
      }
    }
    else if (keyCode == this.VALUEKEY2) {
      if(this.isCONTROLKEY )
      {
        if(outmute)
        {
          out.addSignal(pb);
          outmute = false;
        }
        else {
          out.removeSignal(pb);
          outmute = true;
        }
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
        
        this.vc.put("mode", setMode(1));
        
        println(this.vc.get("mode"));
      }
    }
    else if (keyCode == this.MODEKEY2) {
      if(this.isCONTROLKEY)
      {
        this.vc.put("mode", setMode(-1));
        println(this.vc.get("mode"));
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

      for(int i = 0; i < sh.size(); i++)
      {
        if(!sh.get(i).isMuted())
        {
          outo.addSignal(sh.get(i).GetAudioPlayback());
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
      sh.setThisSampleOrder(PApplet.parseInt(str(key)));
      //println("activeSoundSampleGroup: " + activeSoundSampleGroup);
    }
    else {
      if (sh.getActiveSoundSample() != null)
      {
        //println ("Set sample to group: " + int(str(key)));
        sh.addActiveSoundSampleToGroup(PApplet.parseInt(str(key)));
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


public void handelRemoveSoundSample()
{
  sh.removeCurrentSoundSample();
}

public void handleMute()
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

public void handleRecording()
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

public void sheckmuted()
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

public void dropEvent(DropEvent theDropEvent)
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

public int setMode(int value)
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

public void stop()
{
  sh.CloseSoundSamples();
  out.close();
  in.close();
  minim.stop();
  super.stop();
}




















class ADR implements AudioSignal, AudioListener { //Just a simple "re-route" audio class.
  float[] left, right;
  //Getting.
  public void samples(float[] arg0) {
    left = arg0;
  }

  public void samples(float[] arg0, float[] arg1) {
    left = arg0;
    right = arg1;
  }
  //Sending back.
  public void generate(float[] arg0) {
    System.arraycopy(left, 0, arg0, 0, arg0.length);
  }

  public void generate(float[] arg0, float[] arg1) {
    //System.out.println(arg0[0]);
    if (left!=null && right!=null){
      //println("Left: " + arg0.length + " " + left.length);
      //println("Right: " + arg1.length + " " + right.length);
      System.arraycopy(left, 0, arg0, 0, arg0.length);
      System.arraycopy(right, 0, arg1, 0, arg1.length);
    }
  }
}







class AudioPlayback implements AudioSignal, AudioListener { //Just a simple "re-route" audio class.
  float[] left, right;
  //Getting.
  public void samples(float[] arg0) {
    left = arg0;
  }

  public void samples(float[] arg0, float[] arg1) {
    left = arg0;
    right = arg1;
  }
  //Sending back.
  public void generate(float[] arg0) {
    System.arraycopy(left, 0, arg0, 0, arg0.length);
  }

  public void generate(float[] arg0, float[] arg1) {
    //System.out.println(arg0[0]);
    if (left!=null && right!=null){
      //println("Left: " + arg0.length);
      //println("Right: " + arg1.length);
      System.arraycopy(left, 0, arg0, 0, arg0.length);
      System.arraycopy(right, 0, arg1, 0, arg1.length);
    }
  }
}







class PauseSample extends Sample
{
  public void PauseSample()
  {}
}






class Recorder
{
  public Recorder(Recordable recordSource)
  {
    minim.createRecorder(recordSource, "temp.wav", false);
  }
}






class RecorderHandler
{
  public void RecorderHandler()
  {}
  
  public void add()
  {}
  
  public void get()
  {}
  
  public void remove()
  {}
}






class Sample
{
  int _group = 0;
  int _length = 0;
  int _type = 0;
  int _order = 0;

  boolean _paused = false;
  boolean _looping = false;
  boolean _playing = false;
  
  public void Sample()
  {
  }
  
  public void pause()
  {
  }
  
  public void play()
  {
  }
  
  public void stop()
  {
  }
  
  public void loop()
  {
  }
  
  public void close()
  {
  }
  
  public int length()
  {
    return this._length;
  }
  
  public boolean isPaused()
  {
    return this._paused;
  }
  
  public boolean isPlaying()
  {
    return this._playing;
  }
  
  public boolean isLooping()
  {
    return this._looping;
  }
  
  public void setGroup(int group)
  {
    this._group = group;
  }
  
  public int getGroup()
  {
    return this._group;
  }
  
  public void setType(int type)
  {
    this._type = type;
  }
  
  public int getType()
  {
    return this._type;
  }
  
  public void setOrder(int order)
  {
    this._order = order;
  }
  
  public int getOrder()
  {
    return this._order;
  } 
  
}






class SoundSampleGroup extends Sample
{    
    private int groupId;
    private int playDelay;
    private ArrayList _samples;
    
    //ArrayList _samples = new ArrayList();
  
    public SoundSampleGroup(int groupId)
    {
      super();
      this.groupId = groupId;
      this._samples = new ArrayList();
    }
    
    public int getGroupId()
    {
      return this.groupId;
    }
    
    public void addSoundSample(SoundSample sample)
    {
      _samples.add(sample);
    }
    
    public void removeSoundSample(SoundSample sample)
    {
      //println("Try to Remove from group."); 
      if(_samples.size() > 0)
      {
        //println("Try to Remove from group.");
       for(int i = 0; i < _samples.size(); i++)
       {
          if(_samples.get(i) == sample)
          {            
            _samples.remove(i);
            //println("objekt Removed!");
          }
       }
      }
    }

    public void removeSoundSample(int sample)
    {
    
    }
   
    public void setPlayDelay(int playDelay)
    {
      this.playDelay = playDelay;
    }
    
    public int getPlayDelay()
    {
      return this.playDelay;
    }
    
    public int length()
    {
      this._length = 0;
      for (int s = 0; s < this._samples.size(); s++)
      {
            this._length += ((SoundSample)this._samples.get(s)).length();
      }
      return this._length;
    }
    
    public boolean haveOrder(int order)
    {
      if(!this._samples.isEmpty())
      {
      for (int s = 0; s < this._samples.size(); s++)
      {
            if( ((SoundSample)this._samples.get(s)).getOrder() == order)
            {
              return true;
            }
      }
      }
      return false;
    }
  
  public boolean isPlaying()
  {
    if(!this._samples.isEmpty())
    {
    for (int s = 0; s < this._samples.size(); s++)
      {
            if(((SoundSample)this._samples.get(s)).isPlaying())
            {
              return true;
            }
      }
    }
    else if (this._samples.isEmpty())
    {
      return true;
    }
      return false;
  }
  
  public int size()
  {
    return this._samples.size();
  }
  
  public SoundSample get(int s)
  {
    return (SoundSample)this._samples.get(s);
  }
  public void remove(SoundSample s)
  {
  }
  
  public void setOrder(int order)
  {
    this._order = order;
    if(!this._samples.isEmpty())
    {
    for (int s = 0; s < this._samples.size(); s++)
      {
          ((SoundSample)this._samples.get(s)).setOrder(order);
      }
    }
  }
  
  public int currentSampleOrder = 0;
  public int setCurrentSampleOrder()
  {
    currentSampleOrder++;
    if(currentSampleOrder > getHighestSampleOrder())
    {
      currentSampleOrder = 0;
    }
    return currentSampleOrder;
  }
  
  public int getCurrentSampleOrder()
  {
    return currentSampleOrder;
  }
  
  private int getHighestSampleOrder()
  {
    int tmpOrder = 0;
    for (int s = 0; s < this._samples.size(); s++)
    {
          if (((SoundSample)this._samples.get(s)).getOrder() > tmpOrder) 
          {
            tmpOrder = ((SoundSample)this._samples.get(s)).getOrder();
          }
     }
     return tmpOrder;
   }
    
}





class SoundSampleHandler
{
  private ArrayList _samples;

  private int _activesample = 0;

  private PApplet _parent;
  
  private ArrayList _loopGroups;

  private HashMap _groups;

  public SoundSampleHandler(PApplet parent)
  {
    _parent = parent;
    _samples = new ArrayList();
    _groups =  new HashMap();

    //for (int i = 0; i < 10; i++)
    //{
    //  _groups.put(i, new SoundSampleGroup(i));
    //}
  }

  public void add(SoundSample s)
  {
    _samples.add(s);
  }

  public SoundSample get(int i)
  {
    //println("getSOunds");
    return (SoundSample)_samples.get(i);
  }

  public void remove(int i)
  {
    //println(_samples.size());
    _samples.remove(sh.getActiveSoundSample());
    //_samples.remove(i);
    //println(_samples.size());
  }

  public int size()
  {
    return _samples.size();
  }

  public void setActiveSoundSample(int value)
  {
    //Check if input value is postive or negative and change active sample by that info.
    if(this.size() > 0)
    {
      
      if(value > 0)
      {
        if(_activesample + value > this.size()-1) {
          _activesample = 0;
        }
        else {
          _activesample += value;
        }
      }
      else {
        if(_activesample + value < 0){
          _activesample = this.size()-1;

        }
        else {
          _activesample = _activesample + value;

        }
      }
    }
    else
    {
      _activesample =0;
    }
    //println("activesample: " + _activesample); 
  }
  
  public void setLastSoundSampleToActive()
  {
    _activesample = this.size()-1;
  }
  
  public SoundSample getActiveSoundSample()
  {
    if(this.size() > 0){ 
      return this.get(_activesample);
    }
    else {
      return null;
    }
  }

  public int getActiveSoundSampleFalseInt()
  {
    if(this.size() > 0){
      return _activesample + 1 ;
    }
    return _activesample;
  }

  public int getActiveSoundSampleTrueInt()
  {
    return _activesample;
  }
  public void SaveSoundSamples()
  {
    ArrayList tmp_list = new ArrayList();
    tmp_list.add("<?xml version=\"1.0\"?>");
    tmp_list.add("<samples>");
    for(int i = 0; i < this.size(); i++)
    {
      tmp_list.add("<sample name=\"" + this.get(i).GetMetaData().fileName() + "\" group=\""+ this.get(i).getGroup() + "\"></sample>");
    }
    tmp_list.add("</samples>");
    String str [] = (String[])tmp_list.toArray(new String[tmp_list.size()]);
    //tmp_list.toArray(str); 
    saveStrings(millis() + "samples.xml", str);
  }

  public void loadXML(String file)
  {
    XMLElement xml = new XMLElement(_parent, file);
    int numSoundSamples = xml.getChildCount();
    for (int i = 0; i < numSoundSamples; i++)
    {
      XMLElement smp = xml.getChild(i);
      String smpname = smp.getStringAttribute("name");
      String smpgroup = smp.getStringAttribute("group");
      println(smpname);
      println(smpgroup);
      if(smpgroup == null) {
        smpgroup = "0";
      }
      this.loadWAV(smpname, PApplet.parseInt(smpgroup));
    }
  }

  public void loadWAV(String file, int group)
  {
    println("Loading SoundSample for playback: " + file);
    _samples.add(new SoundSample(minim.loadFile(file, 2048)));
    println("Lopping sample: " + file);
    if(((SoundSample)_samples.get(_samples.size()-1)).GetMetaData().length() > 0)
    {
      //((SoundSample)_samples.get(_samples.size()-1)).loop();
      this.addSoundSampleToGroup(((SoundSample)_samples.get(_samples.size()-1)), group);
      this.setActiveSoundSample(1);
    }
    else{
      println("SoundSample is of Zero (0) length, can not play that.");
      ((SoundSample)_samples.get(_samples.size()-1)).close();
      _samples.remove(_samples.size()-1);
    }
  }

  public void loadAudioPlayer(AudioPlayer ap)
  {
    //println("Loading SoundSample for playback: " + file);
    if(ap.getMetaData().length() > 0)
    {
      //new SoundSample(
      _samples.add(new SoundSample(ap));
      //println("jfkkf1");
      //this.addSoundSampleToGroup((SoundSample)(_samples.get(_samples.size()-1)), 0);
      //((SoundSample)_samples.get(_samples.size()-1)).loop();
      //println("jfkkf2");
      this.setActiveSoundSample(1);
    }
    else {
      ap.close();
      println("SoundSample is Zero (0) length, can not play that.");
    }
    //println("Lopping sample: fdfsfdsf");
  }
//(SoundSample)(_samples.get(_samples.size()-1))
  public void CloseSoundSamples()
  {
    for (int i = 0; i < this.size(); i++)
    {
      ((SoundSample)_samples.get(i)).close();
      _samples.clear();
    }
  }
  
  public int currentSampleGroupOrder = 0;
  
  public int counter_this = 0;
  public void groupCheck()
  {
    if(_samples.size() > 0)
    {
      
    Iterator i = _groups.entrySet().iterator();
    boolean testIfPlaying = false;
    SoundSampleGroup groupSoundSamples;
    while (i.hasNext())  
    {
      
      Map.Entry group = (Map.Entry)i.next();
      groupSoundSamples = (SoundSampleGroup)group.getValue();
      if( groupSoundSamples.getOrder() == getCurrentGroupOrder() )
      {
          //println("kdkdk4433");
          if(groupSoundSamples.isPlaying())
          {
             //println("kalle balle"); 
          }
          else
          {
            //println("kdkdk");
            counter_this++;
            //println("counter_this: " + counter_this);
            //println("groupsize:" + groupSoundSamples.size());
            for(int s=0;s < groupSoundSamples.size(); s++)
            {
              //println("-- Start ----");
              //println("under_cuorder: " + groupSoundSamples.getCurrentSampleOrder());
              //println("pre _ sampleorder: " + ((SoundSample)groupSoundSamples.get(s)).getOrder());
              if( ((SoundSample)groupSoundSamples.get(s)).getOrder() == groupSoundSamples.getCurrentSampleOrder() )
              {
                ((SoundSample)groupSoundSamples.get(s)).stop();
                ((SoundSample)groupSoundSamples.get(s)).play();
                 //println("sample: " + s); 
                 //println("sampleorder: " + ((SoundSample)groupSoundSamples.get(s)).getOrder());
              }
              //println("-- End ----");
            }
            int scso = groupSoundSamples.setCurrentSampleOrder();
            //println("set_currentORDER: " + scso);        
          }
      }
      setCurrentGroupOrder();
    }
    }
  }
  
  public void soloCurrentSoundSampleStart()
  {
    for(int i = 0; i < this.size(); i++)
    {
      if(i != _activesample)
      {
        this.get(i).mute();
      }
      else
      {
        this.get(_activesample).unmute();
      }
    }

  }
  
  public void soloCurrentSoundSampleStop()
  {
    for(int i = 0; i < this.size(); i++)
    {
        this.get(i).muteAsBackup(); 
    }

  }
  
  public void addActiveSoundSampleToGroup(int group_id)
  {
    if(!_groups.containsKey(group_id))
    {
      _groups.put(group_id, new SoundSampleGroup(group_id));
      //println("group_created:" + group_id);
    }
    addSoundSampleToGroup(sh.getActiveSoundSample(), group_id);
  }
   public void setThisSampleOrder(int new_order)
   {
     SoundSample smp = sh.getActiveSoundSample();
     smp.setOrder(new_order);
     //int g = smp.getGroup();
     //((SoundSampleGroup)(_groups.get(g))).setOrder(new_order);
   }
  
  private void addSoundSampleToGroup(SoundSample smp, int group_id)
  {
    //println("fdfd2");
    int g = smp.getGroup();
    ((SoundSampleGroup)(_groups.get(g))).removeSoundSample(smp);
    //println("fdfd1");
    smp.setGroup(group_id);
      //  println("fdfd2");
    ((SoundSampleGroup)_groups.get(group_id)).addSoundSample(smp);
        //println("fdfd3");
  }
  
  public void removeCurrentSoundSample()
  {
    //println("Remove Start.");

    int g = sh.getActiveSoundSample().getGroup();
    //println("Remove Step: 1");
    //println("Remove from group: " +g);
    ((SoundSampleGroup)(_groups.get(g))).removeSoundSample(sh.getActiveSoundSample());
    //println("Remove Step: 2");
    ((SoundSample)_samples.get(_activesample)).stop();
    //println("Remove Step: 3");
    ((SoundSample)_samples.get(_activesample)).close();
    //println("Remove Step: 4");
    sh.remove(_activesample);
    setActiveSoundSample(-1);
    //println("Remove End.");
  }
  
  public void setActiveSoundSampleListner(AudioPlayback pb)
  {
    sh.getActiveSoundSample().GetAudioPlayer().addListener(pb);
  }
  

  public int setCurrentGroupOrder()
  {
    currentSampleGroupOrder++;
    if(currentSampleGroupOrder > getHighestGroupOrder())
    {
      currentSampleGroupOrder = 0;
    }
    return currentSampleGroupOrder;
  }
  
  public int getCurrentGroupOrder()
  {
    return currentSampleGroupOrder;
  }
  
  private int getHighestGroupOrder()
  {
    int tmpOrder = 0;

          Iterator i = _groups.entrySet().iterator();
          SoundSampleGroup groupSoundSamples;
        while (i.hasNext())  
        {
      
          Map.Entry group = (Map.Entry)i.next();
          groupSoundSamples = (SoundSampleGroup)group.getValue();
                    if (groupSoundSamples.getOrder() > tmpOrder) 
          {
            tmpOrder = groupSoundSamples.getOrder();
          }
      }

     return tmpOrder;
   }
  
}



      
//      testIfPlaying = false;
//      for (int s = 0; s < groupSoundSamples.size(); s++)
//      {
//        if(((SoundSample)groupSoundSamples.get(s)).isPlaying())
//        {
//          testIfPlaying = true;
//        }
//      }
//      if(!testIfPlaying)
//      {
//        for (int s2 = 0; s2 < groupSoundSamples.size(); s2++)
//        {
//          ((SoundSample)groupSoundSamples.get(s2)).stop();
//          ((SoundSample)groupSoundSamples.get(s2)).play();
//        }
//      }











class SoundSample extends Sample
{
  private AudioMetaData _meta;
  private AudioPlayer _ap;
  
  private AudioPlayback _apb;
  
  //private int _group;

  //private boolean _paused = false;
  //private boolean _looping = false;
  //private boolean _playing = false;
  private boolean _mutebackup = false;

  private int meta_firstrun;

  public SoundSample(AudioPlayer ap)
  {
    super();
    _ap = ap;
    _meta = _ap.getMetaData();
    _apb = new AudioPlayback();
    _ap.addListener(_apb);
  }

  public AudioPlayer GetAudioPlayer()
  {
    return _ap;
  }
  
  public AudioPlayback GetAudioPlayback()
  {
    return _apb;
  }

  public AudioMetaData GetMetaData()
  {
    return _meta;
  }

  public boolean isPaused()
  {
    if (!this.isPlaying() && this.isLooping()) {
      return true;
    }
    else {
      return false;
    }

  }
  public boolean isPlaying()
  {
    return this._ap.isPlaying();
  }
  public boolean isLooping()
  {
    return this._looping;
  }

  public void pause()
  {
    this._ap.pause();
    this._paused = true;
    this._looping = false;
    this._playing = false;
  }
  public void play()
  {
    this._ap.play();
    this._paused = false;
    this._looping = false;
    this._playing = true;
  }
  public void loop()
  {
    this._ap.loop();
    this._paused = false;
    this._looping = true;
    this._playing = false;
  }

  public void close()
  {
    this._ap.close();
  }
  
  public void setGroup(int group)
  {
    this._group = group;
  }
  
  public int getGroup()
  {
    return this._group;
  }

  public void mute()
  {
    _mutebackup = this._ap.isMuted();
    this._ap.mute();
  }
  public void unmute()
  {
    this._ap.unmute();
  }
  
  public boolean getMuteBackup()
  {
    return _mutebackup;  
  }
  public void muteAsBackup()
  {
    if(_mutebackup)
    {
      this.mute();
    }
    else {
      this.unmute();
    }
  }
  
  public boolean isMuted()
  {
    return this._ap.isMuted();
  }

  public void stop()
  {
    this.pause();
    this._ap.rewind();
  }
  
  public int length()
  {
    return this._ap.length();
  }
}





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
      text("Lenght: " + vc.get("length").toString(), (width/4)*2.5f, (height/10));
      text("Postion: " + vc.get("position").toString(), (width/10), (height/3)*1.2f);
      text("Group: " + vc.get("samplegroup").toString(), (width/10), (height/3)*2.2f);
      text("Order: " + vc.get("sampleorder").toString(), (width/10), (height/3)*2.35f);
     
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
    text("Recordingtime: " + vc.get("recordingtime").toString(), (width/10), (height/3)*1.5f);
    text("ActiveSoundSampleGroup: " + vc.get("activeSoundSampleGroup").toString(), (width/10), (height/3)*1.7f);
    text("Auto Recordingtime: " + vc.get("automaticRecodingLenght").toString(), (width/10), (height/3)*2.5f);
    text("Recordingdelay: " + vc.get("recodingdelay").toString(), (width/10), (height/3)*2.7f);
    text("TakeRecording: " + vc.get("TakeRecording").toString(), (width/10), (height/3)*2.9f);
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















class VisualCollection extends HashMap
{

  HashMap _vcArrays;
  int position;

  HashMap VisualCollectionHashMap;
  
  int mode;
  public VisualCollection()
  {
    super();
    this._vcArrays = new HashMap();
    this.VisualCollectionHashMap = new HashMap();
  }

  public void ChangeVCMode(int m)
  {
    this.mode = m;
  }

  public void AddVCArray(float [] vcarray, String name)
  {
    this._vcArrays.put(name, vcarray);  
  }

  public float[] GetVCArray(String name)
  {
    return (float[])this._vcArrays.get(name);
  }
  
  public void put(SoundSample smp)
  {
    this.put("sampleft", smp.GetAudioPlayer().left.toArray());
    this.put("sampright", smp.GetAudioPlayer().right.toArray());
    this.put("position", smp.GetAudioPlayer().position());
    this.put("length", smp.length());
    String fnam [] = split(sh.getActiveSoundSample().GetMetaData().fileName(), '\\');
    this.put("filename", fnam[fnam.length-1]);
    this.put("samplegroup", smp.getGroup());
    this.put("sampleorder", smp.getOrder());
  }
  
}









  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#F0F0F0", "Polly" });
  }
}
