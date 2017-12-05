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
	int len;
	int chars = 0;
	int wordcount = 0;

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
	while ((len = f.read(line)) > 0) {

	    // total lines
	    lines++;

	    System.out.println(lines);
	    System.out.println(line.length);
	    System.out.println(line);

	    // NOTE: could also use file's length property
	    // total chars
	    chars += len;

	    // convert char array to string...
	    String s = new String(line);

	    // split into words
	    String[] words = s.split(" ");

	    // and count
	    wordcount += words.length;

	    // TODO: debugging only
	    //	    System.out.println(len);

	    // for each character in line, record ASCII code for later count
	    //	    for (int i=0; i<len; i++) {
	    //		System.out.println(line[i]);
	    //	    }

	    // TODO: this is for debugging only, comment it later;
	    //	    System.out.println(line);

	}

	// TODO: this is just testing, actually print to file
	System.out.print("LINES: ");
	System.out.println(lines);
	System.out.print("WORDS: ");
	System.out.println(wordcount);
	System.out.print("CHARACTERS: ");
	System.out.println(chars);


    }

}

