package edu.buffalo.cse.laasie;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.HashSet;
import java.util.Iterator;

public class FlatLog implements LogType{
	Timer time = new Timer();
	Set<Variable> dependencies = new HashSet<Variable>();
	public static List<Function> flatLog = new ArrayList<Function>();
	public List<Function> stack = new ArrayList<Function>();

	public void write(Function f) {
		flatLog.add(f);
	}

	public List<Function> read(Variable v) {
		Function f;
		int logHead = flatLog.size();
		boolean found = false;
		for (int i = logHead - 1; i >= 0; i--) {
			f = flatLog.get(i);
			if(found == false){
				if (f.getWriteDep().equals(v)) {
					List<Variable> readDeps = f.getReadDeps();
					stack.add(f);
					for (Variable dep : readDeps) {
						dependencies.add(dep);
					}
					found = true;
				}
				//found = true;
			}else{
			if (dependencies.contains(f.getWriteDep())) {
				stack.add(f);
				dependencies.remove(f);
				List<Variable> depsDeps = f.getReadDeps();
				for (Variable dep : depsDeps) {
					dependencies.add(dep);
				}
			}			
			 if(dependencies.size() <= 0){ break; }
			}
		}

		return stack;
	}
	
	public Iterator<Function> iterRead(Variable v) { return read(v).iterator(); }
}
