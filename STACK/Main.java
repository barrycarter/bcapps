import java.util.Scanner;


public class Main {

    public static void main(String args[]) {

	// use an array of integers, in part so we can sort it later
	int[] sides = new int[3];

	// only one word changes when we ask for the sides
	String[] ordinals = new String[]{"first", "second", "third"};
	//	ordinals = ["first", "second", "third"];
	//	ordinals[0] = "first";
	//	ordinals[1] = "second";
	//	ordinals[2] = "third";

	// the question we will ask
	StringBuffer q = new StringBuffer();

	// to store the input
        Scanner input = new Scanner(System.in);

	for (int i=0; i<3; i++) {
	    System.out.println("What is the "+ordinals[i]+" side of the Triangle?");
	    sides[i] = input.nextInt(); 
	}

	int side1=0, side2=0, side3=0, side1s=0, side2s=0, side3s=0;

	Boolean Triangle;
        String TriangleType;

        if(side1 + side2 > side3) {
            Triangle = true;
            System.out.println("The triangle is true!");

        } else {
            Triangle = false;
            System.out.println("The Triangle is False!");
            return;

        }

        if(Triangle == true) {
            side1s = side1 * side1;
            side2s = side2 * side2;
            side3s = side3 * side3;

            if(side1s + side2s == side3s) {
                TriangleType = "Right";

                System.out.println("The Triangle is..." + TriangleType);



            } else if (side1s + side2s > side3s) {
                TriangleType = "Acute";

                System.out.println("The Triangle is..." + TriangleType);

            } else if(side1s + side2s < side3s) {
                TriangleType = "Obtuse";

                System.out.println("The Triangle is..." + TriangleType);

            } else {
                TriangleType = null;

                System.out.println("The Triangle is..." + TriangleType);



            }



        }
    }






}
