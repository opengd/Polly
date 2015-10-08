class SoundSample extends Sample
{
  private AudioMetaData _meta;
  private AudioPlayer _ap;
  
  private AudioPlayback _apb;
  
  private boolean _mutebackup = false;

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
  
   
 public void setBalance(float val)
 {
   _ap.setBalance(val);
   _ap.setPan(val);
 } 
 public float  getBalance()
 {
   //println("gain: " + _ap.getGain());
   //println("pan: " + _ap.getPan());
   //println("volume: " + _ap.getVolume());
   return _ap.getBalance();
 }
 public void setGain(float val)
 {
   //_ap.setVolume(val);
   _ap.setGain(val);
 } 
 public float getGain()
 {
   //println("gain: " + _ap.getGain());
   //println("pan: " + _ap.getPan());
   //println("volume: " + _ap.getVolume());
   return _ap.getGain();
 }
 
}






