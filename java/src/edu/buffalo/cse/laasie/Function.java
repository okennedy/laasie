package edu.buffalo.cse.laasie;
import java.util.List;
//this is a functor to be used for passing functions to functions

public interface Function { 	
	public Variable getWriteDep();
	public List<Variable> getReadDeps();
}
