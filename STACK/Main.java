import java.util.Scanner;
import java.util.Arrays;

public class Main {

    public static void main(String args[]) {

	// TODO: really limit yourself to integer-sided triangles only?
	// use an array of integers, in part so we can sort it later
	int[] sides = new int[3];

	// only one word changes when we ask for the sides
	String[] ordinals = new String[]{"first", "second", "third"};

	// to store the input
        Scanner input = new Scanner(System.in);

	for (int i=0; i<3; i++) {
	    // TODO: check for negative or zero values here?
	    System.out.println("What is the "+ordinals[i]+" side of the Triangle?");
	    sides[i] = input.nextInt(); 
	}

	// sort the sides
	Arrays.sort(sides);

	// handle the 'false' case first to avoid if-then-else
	if (sides[0]+sides[1]<=sides[2]) {
            System.out.println("The Triangle is False!");
	    return;
	}

	// we know the triangle is true, so print it

	// TODO: since we're going to say the triangle is
	// acute/right/obtuse anyway, it seems redundant to says its
	// true
	System.out.println("The triangle is true!");

	// compute the difference between the sum of squares of the
	// two shorter sides and the longest side (we only need the
	// sign)
	int diff = sides[0]*sides[0] + sides[1]*sides[1] - sides[2]*sides[2];

	System.out.print("The Triangle is...");

	if (diff==0) {
	    System.out.println("Right");
	} else if (diff < 0) {
	    System.out.println("Acute");
	} else {
	    System.out.println("Obtuse");
	}
	
    }
}
