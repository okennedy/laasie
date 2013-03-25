package edu.buffalo.cse.laasie.test;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import edu.buffalo.cse.laasie.*;

public interface DependencyGenerator {
 
  public enum DepType
  {   NO, 
	  SINGLE, 
	  MULTI};	
	
  public String getDepType();	  
  public List<Variable> generateDeps(Set<Variable> vList);
}