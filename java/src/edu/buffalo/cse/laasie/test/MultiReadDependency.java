package edu.buffalo.cse.laasie.test;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.Set;

import edu.buffalo.cse.laasie.*;

public class MultiReadDependency implements DependencyGenerator {
	
	public DependencyGenerator.DepType type;
	public MultiReadDependency(){
		this.type = DepType.MULTI;
	}
	
	public String getDepType(){
		  return this.type.toString();
	}
	
	public List<Variable> generateDeps(Set<Variable> vList) {
		List<Variable> deps = new ArrayList<Variable>();
		if (vList.size() == 0) {
			return deps;
		} else {
			int numRandomVars = 500;        //new Random().nextInt(vList.size());
			if ((numRandomVars < 2) && (vList.size() >= 2)) {
				numRandomVars = 2;
			}
			Variable v = null;
			int item;
			int k;
			for (int i = 0; i < numRandomVars; i++) {
				//Variable v = vList.get(new Random().nextInt(vList.size()));
				item = new Random().nextInt(vList.size());
				k=0;
				for(Variable variable:vList){
					if(k == item)
						v = variable;
					k++;
				}
				if (!deps.contains(v)) {
					deps.add(v);
				}
			}
			return deps;

		}
	}
}