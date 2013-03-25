package edu.buffalo.cse.laasie;

import java.util.ArrayList;
import java.util.List;
import java.util.Iterator;

public class Log implements LogType{ // methods contained for log manipulation
	Timer timer = new Timer();
	RootTable rootTable = new RootTable();

	// method for writing to the log
	public void write(Function f) {
		LogEntry entry = new LogEntry(f, rootTable, timer);
		rootTable.insert(entry.writeDep, entry);
	}

	// method for reading from the log
	public List<Function> read(Variable v)
	// throws LogException
	{
	//	System.out.println("in read function");
		List<Function> dep = new ArrayList<Function>();
		LogEntry ent = rootTable.fetch(v);
		if (ent == null) {
			//System.err.println("Missing entry in log: " + v);
			//System.err.println("Known Keys: " + rootTable.toString());
			return dep;
		} else {
			trav(ent, dep);
		}
		return dep;
	}

	public void trav(LogEntry l, List<Function> d) {
		for (LogEntry deps : l.readDeps) {
//		System.out.println("Deps" +deps);
//		System.out.println("ReadDeps" + deps.readDeps);
			if (!deps.readDeps.isEmpty()) {
				if((d.contains(deps.op)) == false){
					this.trav(deps, d);
				}
			} else {
				if (!d.contains(deps.op)) {
					d.add(deps.op);
				}
			}
		}
		if (!d.contains(l.op)) {
			d.add(l.op);
		}
		//System.out.println("traversed");
	}

	public Iterator<Function> iterRead(Variable v) {
		LogEntry logEntry = rootTable.fetch(v);
		List<Function> dep = new ArrayList<Function>();
		trav(logEntry, dep);
		Iterator<Function> iterator = dep.iterator();
		return iterator;

	}
}
