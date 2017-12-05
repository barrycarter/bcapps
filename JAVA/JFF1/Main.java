// import necessary classes
import java.io.*;

// NOTE: we are not doing any error checking (just throwing an
// Exception) to keep things simple

class StringManip extends Object {

    public static void main (String argv[]) throws Exception {

	// variable to hold each line of file (assuming no lines over 1M)
	char[] line = new char[1000000];

	// variables to hold output
	int lines = 0;

	// TODO: better to wrap FileReader in BufferedReader, but
	// keeping it simple

	// read the first argument
	String file = argv[0];

	// debug: print filename
	// System.out.println(file);

	// open the file
	FileReader f = new FileReader(file);

	// read the file one line at a time

	// TODO: this may be off by one
	while (f.read(line) > 0) {

	    // TODO: this is for debugging only, comment it later;
	    System.out.println("LINE IS" + line);

	    // add to the lines count
	    lines++;

	}

	// TODO: this is just testing, actually print to file
	System.out.println("LINES: "+lines);


    }

}

