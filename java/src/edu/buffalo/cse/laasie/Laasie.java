package edu.buffalo.cse.laasie;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Random;

import javax.print.attribute.standard.OutputDeviceAssigned;

import edu.buffalo.cse.laasie.util.LaasieArgs;
import edu.buffalo.cse.laasie.test.*;

public class Laasie {
	//class variables
	String inputFile = null;
    String outputFile = null;
    double[] readFractions = new double[100];
    DependencyGenerator.DepType[] dependencies = new DependencyGenerator.DepType[100];
    int numberOfSteps[] = new int[100];
    int numberOfVariables[] = new int[100];
    int logTypes[] = new int[100];
    double depFrac[] = new double[100];
    String[] parameters;
	int lineNumber=0;
	DependencyGenerator dg = null;
	FileWriter outFile = null;
	PrintWriter printer = null;
	

	public static void main(String[] argv) {

		Laasie laasie = new Laasie();
		LaasieArgs args = new LaasieArgs(argv);
    
		/**
		 * code for reading the csv file and running the program 
		 * according to the parameters.
		 */
		while(args.hasNext()){
			try{
				String currArg = args.next();
				if(currArg.equals("-iFile")){
					laasie.inputFile = args.next().toString();
				}else{
					laasie.outputFile = args.next().toString();
				}	
			}catch(Exception exception){
				exception.printStackTrace();
			}
		}
    
		/**
		 * code for reading the file and running the test case
		 */
		try{
			FileInputStream fstream = new FileInputStream(laasie.inputFile);
			DataInputStream dat = new DataInputStream(fstream);
			BufferedReader reader = new BufferedReader(new InputStreamReader(dat));
    	
			String line;
			while((line=reader.readLine()) != null){
				if(laasie.lineNumber == 0){
					laasie.lineNumber++;
					continue;
				}
				laasie.parameters = line.split(",");
				for(int i=0;i<laasie.parameters.length;i++){
					switch(i){
						case 0:
							laasie.readFractions[laasie.lineNumber-1] = Double.parseDouble(laasie.parameters[i]);
							break;
    					case 1:
    						if(laasie.parameters[i].equals("NO"))
    							laasie.dependencies[laasie.lineNumber-1] = DependencyGenerator.DepType.NO;
    						else if(laasie.parameters[i].equals("SINGLE"))
    							laasie.dependencies[laasie.lineNumber-1] = DependencyGenerator.DepType.SINGLE;
    						else
    							laasie.dependencies[laasie.lineNumber-1] = DependencyGenerator.DepType.MULTI;
    						break;
    					case 2:
    						laasie.numberOfSteps[laasie.lineNumber-1] = Integer.parseInt(laasie.parameters[i]);
    						break;
    					case 3:
    						laasie.numberOfVariables[laasie.lineNumber-1] = Integer.parseInt(laasie.parameters[i]);
    						break;
    					case 4:
    						laasie.logTypes[laasie.lineNumber-1] = Integer.parseInt(laasie.parameters[i]);
    						break;
    					case 5:
    						laasie.depFrac[laasie.lineNumber-1] = Double.parseDouble(laasie.parameters[i]);
    						break;
    					default:
    						break;	
					}
				}
				laasie.lineNumber++;
			}
			fstream.close();
		}catch(Exception exception){
			exception.printStackTrace();
		}
    
		/**
		 * initialize the output file
		 */
		try{
			laasie.outFile = new FileWriter(laasie.outputFile);
			laasie.printer = new PrintWriter(laasie.outFile, true);
			//laasie.printer.println("Writes,Reads,Elapsed Time,Read Throughput, Write Throughput,Dependency Type, Variables");
		}catch(Exception exception){
			exception.printStackTrace();
		}
		
		/**
		 * call the readWriteP for generating the results
		 */
    	for(int k = 0; k < laasie.lineNumber-1; k++){
    		if(laasie.dependencies[k] == DependencyGenerator.DepType.NO)
    			laasie.dg = new NoDependency();
    		else if(laasie.dependencies[k] == DependencyGenerator.DepType.SINGLE)
    			laasie.dg = new SingleReadDependency();
    		else
    			laasie.dg = new MultiReadDependency();
    		if(laasie.logTypes[k] == 2){
    			laasie.hugin(laasie.readFractions[k], laasie.numberOfVariables[k], laasie.numberOfSteps[k], laasie.logTypes[k], laasie.dg);
    		}else{
    		laasie.readWriteP(laasie.readFractions[k], laasie.numberOfVariables[k], laasie.numberOfSteps[k], laasie.logTypes[k], laasie.dg, laasie.depFrac[k]);
    		}
    	}
    	
    	//close the output stream.
		try{
			laasie.printer.close();
		}catch(Exception exception){
			exception.printStackTrace();
		}
}
	public void hugin(double readFrac, int var, int steps,int logType, 
            DependencyGenerator depgen){
		HTTPGet httpGet = new HTTPGet();
		DataGenerator test1 = new DataGenerator(steps, depgen, var,null);
		test1.randomFunction(0);
		int numWrites = 0;
		int numReads = 0;
		Random rand = new Random();
		int position = 0;
		String result = "";
		double elapsedTime = 0;
		while(position != test1.dummyFunctionList.size()){	
			if(rand.nextFloat() < readFrac) {
				Variable pathVar = test1.randomVar();
				String urlToRead = "http://mjolnir.cse.buffalo.edu/hugin/ICON/ICON.php?action=read&path=ubdebug/" + pathVar.name + "&safe=YES";
				result = httpGet.getHTML(urlToRead);
				elapsedTime += Double.parseDouble(result.substring(result.indexOf("\"time\":")+7,result.length()-1));
				numReads++;
			} else {
				String urlToRead = "http://mjolnir.cse.buffalo.edu/hugin/ICON/ICON.php?action=write&path=ubdebug/" + test1.dummyFunctionList.get(position).writeDep.name + "&safe=YES&data=\"test\"";
				result = httpGet.getHTML(urlToRead);
				elapsedTime += Double.parseDouble(result.substring(result.indexOf("\"time\":")+7,result.length()-1));
				position++;
				numWrites++;
			}
		}
		this.printer.println(readFrac+" T "+elapsedTime * 1000 +" R "+numReads+" W "+numWrites);
		elapsedTime = 0;	
	}
	
	public void readWriteP(double readFrac, int var, int steps,int logType, 
	                              DependencyGenerator depgen, double depFrac) {
		LogType log = null;
		String LogType = null;
		if(logType == 0){
			 log = new Log();
			 LogType = "Log";
		}else if(logType == 1){
			log = new FlatLog();
			LogType = "FlatLog";
		}
		DataGenerator test1 = new DataGenerator(steps, depgen, var,LogType);
		test1.randomFunction(depFrac);
		
		int numWrites = 0;
		int numReads = 0;
		Random rand = new Random();
//		System.out.println("Reads Percent: " + readFrac*100 + "; Write Percent: "
//				+ (100 - readFrac*100));

		long startTime = System.currentTimeMillis();
		
		int position = 0;
		while(position != test1.dummyFunctionList.size()){	
			if(rand.nextFloat() < readFrac) {
				// The unsuccessful read returns the know key values from the root table. 
				Variable readVar = test1.randomVar();
				//System.out.println(readVar.toString());
				List<Function> ret = log.read(readVar);
				//ret.toString(); // simulate serializing the read
				numReads++;
			} else {
				log.write(test1.dummyFunctionList.get(position));
				position++;
				numWrites++;
			}
		}
		long elapsedTime =(System.currentTimeMillis()-startTime);
    //elapsedTime = elapsedTime/100; 
//		System.out.println("writes,reads,time,write throughput,read throughput,log type,Dep type,Variables to choose from");
//		System.out.println(numWrites + "," + numReads + "," + elapsedTime + "," + numReads/elapsedTime +
//			"," + numWrites/elapsedTime + "," + LogType + "," + depgen.getDepType() + "," + var);
//		System.out.println("printing");
		//System.out.println("time::"+elapsedTime);
		this.printer.println(readFrac+" T "+elapsedTime+" R "+numReads+" W "+numWrites + " Dep " + depgen.getDepType());
		}
	
}
