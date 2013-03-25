package edu.buffalo.cse.laasie;

import static org.junit.Assert.*;

import java.util.ArrayList;
import java.util.List;

import junit.framework.TestCase;
import java.util.Iterator;

public class FlatLogReadTest extends TestCase {

	/*
	 * Test case for the following log entries 
	 * A:= 1 
	 * A:= A + 1 
	 * B:= A 
	 * A:= A+B
	 */

	public void test1() {
		FlatLog log = new FlatLog();
		String s1 = "A";
		String s2 = "B";

		Variable v1 = new Variable(s1);
		Variable v2 = new Variable(s2);

		List<Variable> readDeps1 = new ArrayList<Variable>();

		List<Variable> readDeps2 = new ArrayList<Variable>();
		readDeps2.add(v1);

		List<Variable> readDeps3 = new ArrayList<Variable>();
		readDeps3.add(v1);

		List<Variable> readDeps4 = new ArrayList<Variable>();
		readDeps4.add(v1);
		readDeps4.add(v2);

		DummyFunction df1 = new DummyFunction(v1, readDeps1);
		log.write(df1);
		DummyFunction df2 = new DummyFunction(v1, readDeps2);
		log.write(df2);
		DummyFunction df3 = new DummyFunction(v2, readDeps3);
		log.write(df3);
		DummyFunction df4 = new DummyFunction(v1, readDeps4);
		log.write(df4);
		String Expected = "[(A, []), (A, [A]), (B, [A]), (A, [A, B])]";
		String Actual = "[";
		Iterator<Function> iterator = ((Iterator<Function>) log.iterRead(v1));
		while (iterator.hasNext()) {
			Actual += iterator.next().toString();
			Actual += ", ";
		}
		Actual = Actual.substring(0, Actual.length() - 2);
		Actual += "]";
		assertEquals("Dependencies:" + Actual, Expected, Actual);
	}

	/*
	 * Test case for the following log entries 
	 * A:= 1 
	 * A:= A + 1 
	 * B:= A 
	 * C:= B 
	 * B:= A + C
	 */

	public void test2() {
		FlatLog log = new FlatLog();
		String s1 = "A";
		String s2 = "B";
		String s3 = "C";

		Variable v1 = new Variable(s1);
		Variable v2 = new Variable(s2);
		Variable v3 = new Variable(s3);

		List<Variable> readDeps1 = new ArrayList<Variable>();

		List<Variable> readDeps2 = new ArrayList<Variable>();
		readDeps2.add(v1);

		List<Variable> readDeps3 = new ArrayList<Variable>();
		readDeps3.add(v1);

		List<Variable> readDeps4 = new ArrayList<Variable>();
		readDeps4.add(v2);

		List<Variable> readDeps5 = new ArrayList<Variable>();
		readDeps5.add(v1);
		readDeps5.add(v3);

		DummyFunction df1 = new DummyFunction(v1, readDeps1);
		log.write(df1);
		DummyFunction df2 = new DummyFunction(v1, readDeps2);
		log.write(df2);
		DummyFunction df3 = new DummyFunction(v2, readDeps3);
		log.write(df3);
		DummyFunction df4 = new DummyFunction(v3, readDeps4);
		log.write(df4);
		DummyFunction df5 = new DummyFunction(v2, readDeps5);
		log.write(df5);
		String Expected = "[(A, []), (A, [A]), (B, [A]), (C, [B]), (B, [A, C])]";
		String Actual = "[";
		Iterator<Function> iterator = ((Iterator<Function>) log.iterRead(v2));
		while (iterator.hasNext()) {
			Actual += iterator.next().toString();
			Actual += ", ";
		}
		Actual = Actual.substring(0, Actual.length() - 2);
		Actual += "]";
		assertEquals("Dependencies:" + Actual, Expected, Actual);
	}

	/*
	 * Test case for the following log entries 
	 * B:= 1 
	 * C:= B 
	 * A:= 1 
	 * D:= A + B + C
	 */

	public void test3() {
		FlatLog log = new FlatLog();
		String s1 = "A";
		String s2 = "B";
		String s3 = "C";
		String s4 = "D";

		Variable v1 = new Variable(s1);
		Variable v2 = new Variable(s2);
		Variable v3 = new Variable(s3);
		Variable v4 = new Variable(s4);

		List<Variable> readDeps1 = new ArrayList<Variable>();
		List<Variable> readDeps2 = new ArrayList<Variable>();
		readDeps2.add(v2);
		List<Variable> readDeps3 = new ArrayList<Variable>();
		List<Variable> readDeps4 = new ArrayList<Variable>();
		readDeps4.add(v1);
		readDeps4.add(v2);
		readDeps4.add(v3);

		DummyFunction df1 = new DummyFunction(v2, readDeps1);
		log.write(df1);
		DummyFunction df2 = new DummyFunction(v3, readDeps2);
		log.write(df2);
		DummyFunction df3 = new DummyFunction(v1, readDeps3);
		log.write(df3);
		DummyFunction df4 = new DummyFunction(v4, readDeps4);
		log.write(df4);

		String Expected = "[(B, []), (C, [B]), (A, []), (D, [A, B, C])]";
		String Actual = "[";
		Iterator<Function> iterator = ((Iterator<Function>) log.iterRead(v4));
		while (iterator.hasNext()) {
			Actual += iterator.next().toString();
			Actual += ", ";
		}
		Actual = Actual.substring(0, Actual.length() - 2);
		Actual += "]";
		assertEquals("Dependencies:" + Actual, Expected, Actual);
	}

	/*
	 * Test case for the following log entries 
	 * A:= 1 
	 * B:= A 
	 * C:= 1 
	 * D:= B + C 
	 * E:= D + A
	 */

	public void test4() {
		FlatLog log = new FlatLog();
		String s1 = "A";
		String s2 = "B";
		String s3 = "C";
		String s4 = "D";
		String s5 = "E";

		Variable v1 = new Variable(s1);
		Variable v2 = new Variable(s2);
		Variable v3 = new Variable(s3);
		Variable v4 = new Variable(s4);
		Variable v5 = new Variable(s5);

		List<Variable> readDeps1 = new ArrayList<Variable>();
		List<Variable> readDeps2 = new ArrayList<Variable>();
		readDeps2.add(v1);
		List<Variable> readDeps3 = new ArrayList<Variable>();
		List<Variable> readDeps4 = new ArrayList<Variable>();
		readDeps4.add(v2);
		readDeps4.add(v3);
		List<Variable> readDeps5 = new ArrayList<Variable>();
		readDeps5.add(v4);
		readDeps5.add(v1);

		DummyFunction df1 = new DummyFunction(v1, readDeps1);
		log.write(df1);
		DummyFunction df2 = new DummyFunction(v2, readDeps2);
		log.write(df2);
		DummyFunction df3 = new DummyFunction(v3, readDeps3);
		log.write(df3);
		DummyFunction df4 = new DummyFunction(v4, readDeps4);
		log.write(df4);
		DummyFunction df5 = new DummyFunction(v5, readDeps5);
		log.write(df5);

		String Expected = "[(A, []), (B, [A]), (C, []), (D, [B, C]), (E, [D, A])]";
		String Actual = "[";
		Iterator<Function> iterator = ((Iterator<Function>) log.iterRead(v5));
		while (iterator.hasNext()) {
			Actual += iterator.next().toString();
			Actual += ", ";
		}
		Actual = Actual.substring(0, Actual.length() - 2);
		Actual += "]";
		assertEquals("Dependencies:" + Actual, Expected, Actual);
	}

	/*
	 * Test case for the following log entries 
	 * A:= 1 
	 * A:= A + 1 
	 * B:= 1 
	 * B:= A + B
	 * C:= 1 
	 * D:= 1 
	 * D:= D+C+A+B 
	 * A:= 1
	 */

	public void test5() {
		FlatLog log = new FlatLog();
		String s1 = "A";
		String s2 = "B";
		String s3 = "C";
		String s4 = "D";

		Variable v1 = new Variable(s1);
		Variable v2 = new Variable(s2);
		Variable v3 = new Variable(s3);
		Variable v4 = new Variable(s4);

		List<Variable> readDeps1 = new ArrayList<Variable>();
		List<Variable> readDeps2 = new ArrayList<Variable>();
		readDeps2.add(v1);
		List<Variable> readDeps3 = new ArrayList<Variable>();
		List<Variable> readDeps4 = new ArrayList<Variable>();
		readDeps4.add(v1);
		readDeps4.add(v2);
		List<Variable> readDeps5 = new ArrayList<Variable>();
		List<Variable> readDeps6 = new ArrayList<Variable>();
		List<Variable> readDeps7 = new ArrayList<Variable>();
		readDeps7.add(v4);
		readDeps7.add(v3);
		readDeps7.add(v1);
		readDeps7.add(v2);
		List<Variable> readDeps8 = new ArrayList<Variable>();
		

		DummyFunction df1 = new DummyFunction(v1, readDeps1);
		log.write(df1);
		DummyFunction df2 = new DummyFunction(v1, readDeps2);
		log.write(df2);
		DummyFunction df3 = new DummyFunction(v2, readDeps3);
		log.write(df3);
		DummyFunction df4 = new DummyFunction(v2, readDeps4);
		log.write(df4);
		DummyFunction df5 = new DummyFunction(v3, readDeps5);
		log.write(df5);
		DummyFunction df6 = new DummyFunction(v4, readDeps6);
		log.write(df6);
		DummyFunction df7 = new DummyFunction(v4, readDeps7);
		log.write(df7);
		DummyFunction df8 = new DummyFunction(v1, readDeps8);
		log.write(df8);

		String Expected = "[(A, []), (A, [A]), (B, []), (B, [A, B]), (C, []), (D, []), (D, [D, C, A, B])]";
		String Actual  = "[";
		Iterator<Function> iterator = ((Iterator<Function>) log.iterRead(v4));
	
		while (iterator.hasNext()) {
			Actual += iterator.next().toString();
			Actual += ", ";
		}
		Actual = Actual.substring(0, Actual.length() - 2);
		Actual += "]";
		assertEquals("Dependencies:" + Actual, Expected, Actual);
	}

	/*
	 * Test case for the following log entries 
	 * A:= 1 
	 * A:= A + 1 
	 * B:= 1 
	 * B:= A + B
	 * C:= 1 
	 * D:= 1 
	 * D:= D+C+A+B 
	 * D:= D+C+A+B
	 */

	public void test5_2() {
		FlatLog log = new FlatLog();
		String s1 = "A";
		String s2 = "B";
		String s3 = "C";
		String s4 = "D";

		Variable v1 = new Variable(s1);
		Variable v2 = new Variable(s2);
		Variable v3 = new Variable(s3);
		Variable v4 = new Variable(s4);

		List<Variable> readDeps1 = new ArrayList<Variable>();
		List<Variable> readDeps2 = new ArrayList<Variable>();
		readDeps2.add(v1);
		List<Variable> readDeps3 = new ArrayList<Variable>();
		List<Variable> readDeps4 = new ArrayList<Variable>();
		readDeps4.add(v1);
		readDeps4.add(v2);
		List<Variable> readDeps5 = new ArrayList<Variable>();
		List<Variable> readDeps6 = new ArrayList<Variable>();
		List<Variable> readDeps7 = new ArrayList<Variable>();
		readDeps7.add(v4);
		readDeps7.add(v3);
		readDeps7.add(v1);
		readDeps7.add(v2);

		DummyFunction df1 = new DummyFunction(v1, readDeps1);
		log.write(df1);
		DummyFunction df2 = new DummyFunction(v1, readDeps2);
		log.write(df2);
		DummyFunction df3 = new DummyFunction(v2, readDeps3);
		log.write(df3);
		DummyFunction df4 = new DummyFunction(v2, readDeps4);
		log.write(df4);
		DummyFunction df5 = new DummyFunction(v3, readDeps5);
		log.write(df5);
		DummyFunction df6 = new DummyFunction(v4, readDeps6);
		log.write(df6);
		DummyFunction df7 = new DummyFunction(v4, readDeps7);
		log.write(df7);
		DummyFunction df8 = new DummyFunction(v4, readDeps7);
		log.write(df8);

		String Expected = "[(A, []), (A, [A]), (B, []), (B, [A, B]), (C, []), (D, []), (D, [D, C, A, B]), (D, [D, C, A, B])]";
		String Actual = "[";
		Iterator<Function> iterator = ((Iterator<Function>) log.iterRead(v4));
		while (iterator.hasNext()) {
			Actual += iterator.next().toString();
			Actual += ", ";
		}
		Actual = Actual.substring(0, Actual.length() - 2);
		Actual += "]";
		assertEquals("Dependencies:" + Actual, Expected, Actual);
	}

	/*
	 * Test case for the following log entries 
	 * B:= 1 
	 * C:= 1 
	 * A:= B+C 
	 * C:= 1 
	 * D:= A+B+C 
	 * A:= A+B+C+D
	 */

	public void test6() {
		FlatLog log = new FlatLog();
		String s1 = "A";
		String s2 = "B";
		String s3 = "C";
		String s4 = "D";

		Variable v1 = new Variable(s1);
		Variable v2 = new Variable(s2);
		Variable v3 = new Variable(s3);
		Variable v4 = new Variable(s4);

		List<Variable> readDeps1 = new ArrayList<Variable>();
		List<Variable> readDeps2 = new ArrayList<Variable>();
		readDeps2.add(v2);
		readDeps2.add(v3);
		List<Variable> readDeps3 = new ArrayList<Variable>();
		readDeps3.add(v1);
		readDeps3.add(v2);
		readDeps3.add(v3);
		List<Variable> readDeps4 = new ArrayList<Variable>();
		readDeps4.add(v1);
		readDeps4.add(v2);
		readDeps4.add(v3);
		readDeps4.add(v4);

		DummyFunction df1 = new DummyFunction(v2, readDeps1);
		log.write(df1);
		DummyFunction df2 = new DummyFunction(v3, readDeps1);
		log.write(df2);
		DummyFunction df3 = new DummyFunction(v1, readDeps2);
		log.write(df3);
		DummyFunction df4 = new DummyFunction(v3, readDeps1);
		log.write(df4);
		DummyFunction df5 = new DummyFunction(v4, readDeps3);
		log.write(df5);
		DummyFunction df6 = new DummyFunction(v1, readDeps4);
		log.write(df6);

		String Expected = "[(B, []), (C, []), (A, [B, C]), (C, []), (D, [A, B, C]), (A, [A, B, C, D])]";
		String Actual = "[";
		Iterator<Function> iterator = ((Iterator<Function>) log.iterRead(v1));
		while (iterator.hasNext()) {
			Actual += iterator.next().toString();
			Actual += ", ";
		}
		Actual = Actual.substring(0, Actual.length() - 2);
		Actual += "]";
		assertEquals("Dependencies:" + Actual, Expected, Actual);
	}

	/*
	 * Test case for the following log entries 
	 * A:= 1 
	 * A:= A+1 
	 * B:= A+1 
	 * C:= A+1 
	 * D:= A+B+C 
	 * D:= A+B+C+D
	 */

	public void test7() {
		FlatLog log = new FlatLog();
		String s1 = "A";
		String s2 = "B";
		String s3 = "C";
		String s4 = "D";

		Variable v1 = new Variable(s1);
		Variable v2 = new Variable(s2);
		Variable v3 = new Variable(s3);
		Variable v4 = new Variable(s4);

		List<Variable> readDeps1 = new ArrayList<Variable>();
		List<Variable> readDeps2 = new ArrayList<Variable>();
		readDeps2.add(v1);
		List<Variable> readDeps3 = new ArrayList<Variable>();
		readDeps3.add(v1);
		readDeps3.add(v2);
		readDeps3.add(v3);
		List<Variable> readDeps4 = new ArrayList<Variable>();
		readDeps4.add(v1);
		readDeps4.add(v2);
		readDeps4.add(v3);
		readDeps4.add(v4);

		DummyFunction df1 = new DummyFunction(v1, readDeps1);
		log.write(df1);
		DummyFunction df2 = new DummyFunction(v1, readDeps2);
		log.write(df2);
		DummyFunction df3 = new DummyFunction(v2, readDeps2);
		log.write(df3);
		DummyFunction df4 = new DummyFunction(v3, readDeps2);
		log.write(df4);
		DummyFunction df5 = new DummyFunction(v4, readDeps3);
		log.write(df5);
		DummyFunction df6 = new DummyFunction(v4, readDeps4);
		log.write(df6);

		String Expected = "[(A, []), (A, [A]), (B, [A]), (C, [A]), (D, [A, B, C]), (D, [A, B, C, D])]";
		String Actual = "[";
		Iterator<Function> iterator = ((Iterator<Function>) log.iterRead(v4));
		while (iterator.hasNext()) {
			Actual += iterator.next().toString();
			Actual += ", ";
		}
		Actual = Actual.substring(0, Actual.length() - 2);
		Actual += "]";
		assertEquals("Dependencies:" + Actual, Expected, Actual);
	}

	/*
	 * Test case for the following log entries 
	 * A:= 1 
	 * A:= A+1 
	 * B:= A+1 
	 * C:= B+1 
	 * D:= C+1 
	 * A:= A+B+C+D 
	 * B:= A+B+C+D 
	 * C:= A+B+C+D 
	 * D:= A+B+C+D
	 */

	public void test8() {
		FlatLog log = new FlatLog();
		String s1 = "A";
		String s2 = "B";
		String s3 = "C";
		String s4 = "D";

		Variable v1 = new Variable(s1);
		Variable v2 = new Variable(s2);
		Variable v3 = new Variable(s3);
		Variable v4 = new Variable(s4);

		List<Variable> readDeps1 = new ArrayList<Variable>();
		List<Variable> readDeps2 = new ArrayList<Variable>();
		readDeps2.add(v1);
		List<Variable> readDeps3 = new ArrayList<Variable>();
		readDeps3.add(v2);
		List<Variable> readDeps4 = new ArrayList<Variable>();
		readDeps4.add(v3);
		List<Variable> readDeps5 = new ArrayList<Variable>();
		readDeps5.add(v1);
		readDeps5.add(v2);
		readDeps5.add(v3);
		readDeps5.add(v4);

		DummyFunction df1 = new DummyFunction(v1, readDeps1);
		log.write(df1);
		DummyFunction df2 = new DummyFunction(v1, readDeps2);
		log.write(df2);
		DummyFunction df3 = new DummyFunction(v2, readDeps2);
		log.write(df3);
		DummyFunction df4 = new DummyFunction(v3, readDeps3);
		log.write(df4);
		DummyFunction df5 = new DummyFunction(v4, readDeps4);
		log.write(df5);
		DummyFunction df6 = new DummyFunction(v1, readDeps5);
		log.write(df6);
		DummyFunction df7 = new DummyFunction(v2, readDeps5);
		log.write(df7);
		DummyFunction df8 = new DummyFunction(v3, readDeps5);
		log.write(df8);
		DummyFunction df9 = new DummyFunction(v4, readDeps5);
		log.write(df9);

		String Expected = "[(A, []), (A, [A]), (B, [A]), (C, [B]), (D, [C]), (A, [A, B, C, D]), (B, [A, B, C, D]), (C, [A, B, C, D]), (D, [A, B, C, D])]";
		String Actual = "[";
		Iterator<Function> iterator = ((Iterator<Function>) log.iterRead(v4));
		while (iterator.hasNext()) {
			Actual += iterator.next().toString();
			Actual += ", ";
		}
		Actual = Actual.substring(0, Actual.length() - 2);
		Actual += "]";
		assertEquals("Dependencies:" + Actual, Expected, Actual);
	}

	/*
	 * Test case for the following log entries 
	 * A:= 1 
	 * B:= A+1 
	 * C:= A+B 
	 * D:= 1 
	 * A:= C+D
	 */

	public void test9() {
		FlatLog log = new FlatLog();
		String s1 = "A";
		String s2 = "B";
		String s3 = "C";
		String s4 = "D";

		Variable v1 = new Variable(s1);
		Variable v2 = new Variable(s2);
		Variable v3 = new Variable(s3);
		Variable v4 = new Variable(s4);

		List<Variable> readDeps1 = new ArrayList<Variable>();
		List<Variable> readDeps2 = new ArrayList<Variable>();
		readDeps2.add(v1);
		List<Variable> readDeps3 = new ArrayList<Variable>();
		readDeps3.add(v1);
		readDeps3.add(v2);
		List<Variable> readDeps4 = new ArrayList<Variable>();
		readDeps4.add(v3);
		readDeps4.add(v4);

		DummyFunction df1 = new DummyFunction(v1, readDeps1);
		log.write(df1);
		DummyFunction df2 = new DummyFunction(v2, readDeps2);
		log.write(df2);
		DummyFunction df3 = new DummyFunction(v3, readDeps3);
		log.write(df3);
		DummyFunction df4 = new DummyFunction(v4, readDeps1);
		log.write(df4);
		DummyFunction df5 = new DummyFunction(v1, readDeps4);
		log.write(df5);

		String Expected = "[(A, []), (B, [A]), (C, [A, B]), (D, []), (A, [C, D])]";
		String Actual = "[";
		Iterator<Function> iterator = ((Iterator<Function>) log.iterRead(v1));
		while (iterator.hasNext()) {
			Actual += iterator.next().toString();
			Actual += ", ";
		}
		Actual = Actual.substring(0, Actual.length() - 2);
		Actual += "]";
		assertEquals("Dependencies:" + Actual, Expected, Actual);
	}

	/*
	 * Test case for the following log entries 
	 * A:= 1 
	 * B:= 1 
	 * C:= 1  
	 * A:= A+B 
	 * B:= A 
	 * C:= B
	 */

	public void test10() {
		FlatLog log = new FlatLog();
		String s1 = "A";
		String s2 = "B";
		String s3 = "C";

		Variable v1 = new Variable(s1);
		Variable v2 = new Variable(s2);
		Variable v3 = new Variable(s3);

		List<Variable> readDeps1 = new ArrayList<Variable>();
		List<Variable> readDeps2 = new ArrayList<Variable>();
		readDeps2.add(v1);
		readDeps2.add(v2);
		List<Variable> readDeps3 = new ArrayList<Variable>();
		readDeps3.add(v1);
		List<Variable> readDeps4 = new ArrayList<Variable>();
		readDeps4.add(v2);

		DummyFunction df1 = new DummyFunction(v1, readDeps1);
		log.write(df1);
		DummyFunction df2 = new DummyFunction(v2, readDeps1);
		log.write(df2);
		DummyFunction df3 = new DummyFunction(v3, readDeps1);
		log.write(df3);
		DummyFunction df4 = new DummyFunction(v1, readDeps2);
		log.write(df4);
		DummyFunction df5 = new DummyFunction(v2, readDeps3);
		log.write(df5);
		DummyFunction df6 = new DummyFunction(v3, readDeps4);
		log.write(df6);

		String Expected = "[(A, []), (B, []), (A, [A, B]), (B, [A]), (C, [B])]";
		String Actual = "[";
		Iterator<Function> iterator = ((Iterator<Function>) log.iterRead(v3));
		while (iterator.hasNext()) {
			Actual += iterator.next().toString();
			Actual += ", ";
		}
		Actual = Actual.substring(0, Actual.length() - 2);
		Actual += "]";
		assertEquals("Dependencies:" + Actual, Expected, Actual);
	}

	/*
	 * Test case for the following log entries 
	 * A:= 1 
	 * B:= A+1 
	 * A:= A+B+1 
	 * C:= 1 B:= A+B+C 
	 * A:= A+B+C
	 */
	public void test11() {
		FlatLog log = new FlatLog();
		String s1 = "A";
		String s2 = "B";
		String s3 = "C";

		Variable v1 = new Variable(s1);
		Variable v2 = new Variable(s2);
		Variable v3 = new Variable(s3);

		List<Variable> readDeps1 = new ArrayList<Variable>();
		List<Variable> readDeps2 = new ArrayList<Variable>();
		readDeps2.add(v1);
		List<Variable> readDeps3 = new ArrayList<Variable>();
		readDeps3.add(v1);
		readDeps3.add(v2);
		List<Variable> readDeps4 = new ArrayList<Variable>();
		List<Variable> readDeps5 = new ArrayList<Variable>();
		readDeps5.add(v1);
		readDeps5.add(v2);
		readDeps5.add(v3);
		List<Variable> readDeps6 = new ArrayList<Variable>();
		readDeps6.add(v1);
		readDeps6.add(v2);
		readDeps6.add(v3);

		DummyFunction df1 = new DummyFunction(v1, readDeps1);
		log.write(df1);
		DummyFunction df2 = new DummyFunction(v2, readDeps2);
		log.write(df2);
		DummyFunction df3 = new DummyFunction(v1, readDeps3);
		log.write(df3);
		DummyFunction df4 = new DummyFunction(v3, readDeps4);
		log.write(df4);
		DummyFunction df5 = new DummyFunction(v2, readDeps5);
		log.write(df5);
		DummyFunction df6 = new DummyFunction(v1, readDeps6);
		log.write(df6);

		String Expected = "[(A, []), (B, [A]), (A, [A, B]), (C, []), (B, [A, B, C]), (A, [A, B, C])]";
		String Actual = "[";
		Iterator<Function> iterator = ((Iterator<Function>) log.iterRead(v1));
		while (iterator.hasNext()) {
			Actual += iterator.next().toString();
			Actual += ", ";
		}
		Actual = Actual.substring(0, Actual.length() - 2);
		Actual += "]";
		assertEquals("Dependencies:" + Actual, Expected, Actual);
	}

}
