package edu.buffalo.cse.laasie;

import java.util.Iterator;
import java.util.List;

public interface LogType {
	public List<Function> read(Variable v);
	public void write(Function f);
	public Iterator<Function> iterRead(Variable v);
	

}
