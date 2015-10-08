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
      this.loadWAV(smpname, int(smpgroup));
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
   
   public void setActiveSampleBalance(float val)
   {
     if(sh.getActiveSoundSample() != null)
     {
       sh.getActiveSoundSample().setBalance(constrainValues(sh.getActiveSoundSample().getBalance(), val, 1.0, -1.0));
     }
   }
   
   public void setActiveSampleGain(float val)
   {
      if(sh.getActiveSoundSample() != null)
     {
       sh.getActiveSoundSample().setGain(constrainValues(sh.getActiveSoundSample().getGain(), val, 6.0, -100.0));
     }
   }
   
   public float constrainValues(float val, float addval, float highest, float lowest)
   {
     if(sh.getActiveSoundSample() != null)
     {
       val = val + addval;
       if(val < lowest)
       {
         val = lowest;
       }
       else if(val > highest)
       {
         val = highest;
       }
       else if(val > -addval && val < addval)
       {
         val = 0;
       }
       //println("new cb: " + cb);
       return val;
     }
     return 0;
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











