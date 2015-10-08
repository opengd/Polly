class Recorder
{
  public Recorder(Recordable recordSource)
  {
    minim.createRecorder(recordSource, "temp.wav", false);
  }
}






