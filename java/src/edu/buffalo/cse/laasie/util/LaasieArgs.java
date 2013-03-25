package edu.buffalo.cse.laasie.util;

public class LaasieArgs {
  String[] args;
  int curr;
  
  public LaasieArgs(String[] args){
    this.args = args;
    this.curr = 0;
  }
  
  protected int nextIndex(){ curr++; return curr-1; }
  
  public String get(int i) { return args[i]; }
  public String next() { return get(nextIndex()); }
  
  public int getInt(int i) { return Integer.parseInt(args[i]); }
  public int nextInt() { return getInt(nextIndex()); }

  public Double getDouble(int i) { return Double.parseDouble(args[i]); }
  public double nextDouble() { return getDouble(nextIndex()); }
  
  public boolean hasNext() { return curr < args.length; }
}