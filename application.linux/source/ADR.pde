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







