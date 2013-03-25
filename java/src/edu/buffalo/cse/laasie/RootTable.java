package edu.buffalo.cse.laasie;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;

// holds pointers to all most recent values and will use the built in methods

public class RootTable { 
	
	HashMap<Variable,LogEntry> table = new HashMap<Variable,LogEntry>();

/*
For each ReadDep var in a list, give me the LogEntry representing the most 
recent wrote to that var.
*/	
  public List<LogEntry> mapEntries(List<Variable> vars){
    List<LogEntry> rdVars = new ArrayList<LogEntry>();
    for(Variable v:vars){
      rdVars.add(table.get(v));
    }
    return rdVars;
	}
	
	public void insert(Variable v, LogEntry entry){
    table.put(v,entry);
	}
	
	public LogEntry fetch(Variable v){
		return table.get(v);
	}
	
	public String toString(){
    return table.keySet().toString();
	}
	
}
