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









