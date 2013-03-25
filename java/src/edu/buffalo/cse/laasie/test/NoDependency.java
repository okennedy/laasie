package edu.buffalo.cse.laasie.test;

import java.util.HashSet;
import java.util.List;
import java.util.ArrayList;
import java.util.Set;

import edu.buffalo.cse.laasie.*;
import edu.buffalo.cse.laasie.test.DependencyGenerator.DepType;

public class NoDependency implements DependencyGenerator {
	
  public DependencyGenerator.DepType type;
  public NoDependency(){
	this.type = DepType.NO;
  }
  
  public String getDepType(){
	  return this.type.toString();
  }
  
  public List<Variable> generateDeps(Set<Variable> vList){
    return new ArrayList<Variable>();
  }
}