class Sample
{
  int _group = 0;
  int _length = 0;
  int _type = 0;
  int _order = 0;

  boolean _paused = false;
  boolean _looping = false;
  boolean _playing = false;
  
  void Sample()
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






