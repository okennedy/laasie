package edu.buffalo.cse.laasie.test;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.Set;

import edu.buffalo.cse.laasie.*;
import edu.buffalo.cse.laasie.test.DependencyGenerator.DepType;

public class SingleReadDependency implements DependencyGenerator {
	
	public DependencyGenerator.DepType type;
	public SingleReadDependency(){
		this.type = DepType.SINGLE;
	}
	
	public String getDepType(){
		  return this.type.toString();
	}
	
	public List<Variable> generateDeps(Set<Variable> vList) {
		List<Variable> deps = new ArrayList<Variable>();

		if(vList.size() == 0){
			return deps; 
		}else{ 
			Variable v = null;
			int item;
			int k;
			item = new Random().nextInt(vList.size());
			k=0;
			for(Variable variable:vList){
				if(k == item)
					v = variable;
				k++;
			}
			deps.add(v);
		}
		return deps;
		/*
		int item = new Random().nextInt(size); 
		int i = 0;
		for(Variable v : vList)
		{
		  if (i == item){
			  deps.add(v);
		  }
			  i = i + 1;
		}
		return deps;
		*/
	}
}