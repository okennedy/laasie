package edu.buffalo.cse.laasie;

public class Timer {
  int time;
  
  public Timer(){
    this.time = 0;
  }
  
  public int getTimestamp(){
    return ++time;
  }
}
