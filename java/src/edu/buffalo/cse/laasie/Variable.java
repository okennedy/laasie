package edu.buffalo.cse.laasie;

public class Variable {
  String name;
  
  public Variable(String name){
    this.name = name;
  }
  
  public boolean equals(Object o){
    try {
      return ((Variable)o).name.equals(name);
    } catch(ClassCastException e){
      return false;
    }
  }
  
  public int hashCode(){
    return name.hashCode();
  }
  
  public String toString(){
    return "["+name+"]";
  }
}