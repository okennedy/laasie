package edu.buffalo.cse.laasie;

import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;

public class FlatLogRecursive {
	Timer time = new Timer();
	public static List<Function> flatLog = new ArrayList<Function>();
	public List<Function> stack = new ArrayList<Function>();
	int stackHead = 0;

	public void write(Function f) {
		flatLog.add(f);
	}

	public Iterator<Function> read(Variable v) {
		buildStack(flatLog.size(), v);
		return stack.iterator();

	}

	public void test() {
		Iterator<Function> i = stack.iterator();
		while (i.hasNext()) {
			System.out.println(i.next().toString());
		}
	}

	public void testFlatLog() {
		Iterator<Function> it = flatLog.iterator();
		while (it.hasNext()) {
			System.out.println(((Function) it.next()).getWriteDep().name);
		}
	}

	public List<Function> buildStack(int logHead, Variable v) {
		Function f;
		for (int i = logHead - 1; i >= 0; i--) {
			f = flatLog.get(i);
			if (((f.getWriteDep()).name).equals(v.name)) {
				List<Variable> varList = f.getReadDeps();
				Iterator<Variable> varIterator = varList.iterator();
				stack.add(f);
				stackHead++;
				while (varIterator.hasNext()) {
					Variable v1 = varIterator.next();
					buildStack(i, v1);
				}
				break;
			}
		}
		return stack;
	}
}
