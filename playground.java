import java.util.Scanner;

/**
 * @author Sartaj Singh
 */
public class playground {

    public static void main(String[] args) {

        int choice = 0;
	// -1 to make sure its negative
        double weight = -1.;
	// the 0/"" is so I can match array indexes to numbers
	double[] gravs = {0, 3.7/9.81, 8.87/9.81, 1.622/9.81, 24.79/9.81};
	String[] names = {"", "Mercury", "Venus", "Moon", "Jupiter"};

        System.out.println("Welcome to Planetary Weight Calculator: ");
        Scanner input = new Scanner(System.in);

	do {
	    System.out.print("Enter your weight in pounds (lb): ");
            weight = input.nextDouble();
	    if (weight <= 0) {
		System.out.println("Invalid Input - Plase enter a value higher than 0 ");
	    }
	} while (weight <= 0);

	do {
	    System.out.println("/////MENU/////");
	    for (int i=1; i<=4; i++) {
		System.out.format("%d %s\n", i, names[i]);
	    }
	    choice = input.nextInt();
	} while (choice <= 0 || choice >=5);

	System.out.format("You selected %s, your weight on %s is %f lbs\n", names[choice], names[choice], weight*gravs[choice]);
        System.out.println("Thank you for using the Planetary Weight Calculator");
        System.out.println("Hope you will use it again! ");
    }
}
