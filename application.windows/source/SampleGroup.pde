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





