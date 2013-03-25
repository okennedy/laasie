package edu.buffalo.cse.laasie.test;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.Set;

import edu.buffalo.cse.laasie.*;

public class DataGenerator {
  public List<DummyFunction> dummyFunctionList = new ArrayList<DummyFunction>();
  //ArrayList<Variable> vars = new ArrayList<Variable>();
  Set<Variable> vars = new HashSet<Variable>();
  Random rand = new Random();
  int numVars;
  int numWrites;
  DependencyGenerator depGen;
  String depType;
  //List<Variable> variableList = new ArrayList<Variable>();
  Set<Variable> variableList = new HashSet<Variable>();
  
  public DataGenerator(int numWrites, DependencyGenerator depGen,int numVars,String depType) {
//    System.out.println("number of steps: " + numWrites + "; variables to choose from: " + numVars);
    this.depType = depType;
    this.numVars = numVars;
    this.numWrites=numWrites;
    this.depGen = depGen;
  }
  
  public void importState(DataGenerator oldGen) {
    variableList.addAll(oldGen.variableList);
  }
  
  public void randomFunction(double depFrac) {
	  int numberOfNoDep = numWrites - ((int) (numWrites*depFrac));
	  List<Variable> nodepList = new ArrayList<Variable>();
    for(int i =0;i<numWrites;i++){
    	Variable v = this.randomVar(); 
    	if(i <= numberOfNoDep){
    		DummyFunction df = new DummyFunction(v,nodepList);
    		dummyFunctionList.add(df);
    	     continue;
    	}
      
      List<Variable> readDeps = depGen.generateDeps(variableList);
      if(!variableList.contains(v)) {
        variableList.add(v);
      }
//      System.out.println("variable:" + v + "readDependencys:" + readDeps);
      DummyFunction df = new DummyFunction(v,readDeps);
      dummyFunctionList.add(df);
    }
  }
  
  public Variable randomVar() {
    return new Variable(
      Integer.toString(rand.nextInt(numVars))
    );
  }
  
  
}