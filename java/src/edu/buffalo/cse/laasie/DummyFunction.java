package edu.buffalo.cse.laasie;

import java.util.List;

public class DummyFunction implements Function { 
  Variable writeDep;
  List<Variable> readDeps;
  String functionName;
  
  public DummyFunction(Variable writeDep, List<Variable> readDeps)
  {
    this.writeDep = writeDep;
    this.readDeps = readDeps;
  }
  
  
  public String toString()
  {
    StringBuilder sb = new StringBuilder("(");
    sb.append(this.writeDep.name);
    sb.append(", [");
    String sep = "";
    for(Variable dep : readDeps){
      sb.append(sep);
      sb.append(dep.name);
      sep = ", ";
    }
    sb.append("])");
    return sb.toString();
  }
  
	public Variable getWriteDep()
	{
		return this.writeDep;
	}
	public List<Variable> getReadDeps()
	{
		return this.readDeps;
	}
}
