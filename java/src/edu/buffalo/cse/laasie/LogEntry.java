package edu.buffalo.cse.laasie;
import java.util.List;

public class LogEntry {
  Variable writeDep;
  List<Variable> readDepVars;
  List<LogEntry> readDeps;
  
  int timestamp;
  
  Function op;
  
  
  public LogEntry(Function op, RootTable root, Timer timer){
    this.op = op;
    this.writeDep = op.getWriteDep();
    this.readDepVars = op.getReadDeps();
    this.readDeps = root.mapEntries(this.readDepVars);
    this.timestamp = timer.getTimestamp();
  }
  
  public String toString() {
    return op.toString() + readDeps.toString() ;
  }
  
}
