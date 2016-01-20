package project2;

import java.util.Scanner;

/**
 * @author Sartaj Singh
 */
public class Project2 {

    public static void main(String[] args) {

        int choice = 0;
        double weight;
        double earth = 9.81;
        double moon = 1.622;
        double mercury = 3.7;
        double venus = 8.87;
        double jupiter = 24.79;

        System.out.println("Welcome to Planetary Weight Calculator: ");
        Scanner input = new Scanner(System.in);
        System.out.print("Enter your weight in pounds (lb): ");
        weight = input.nextDouble();
        while (weight <= 0) {
            System.out.println("Invalid Input - Plase enter a value higher than 0 ");
            System.out.print("Enter your weight in pounds (lb): ");
            weight = input.nextDouble();
        }
        System.out.println("/////MENU/////");
        System.out.println("1 - Moon");
        System.out.println("2 - Mercury");
        System.out.println("3 - Venus");
        System.out.println("4 - Jupiter");
        System.out.print("Pick a number 1-4: ");
        choice = input.nextInt();
        while (choice <= 0 || choice >= 5) {
            System.out.println("/////MENU/////");
            System.out.println("1 - Moon");
            System.out.println("2 - Mercury");
            System.out.println("3 - Venus");
            System.out.println("4 - Jupiter");
            System.out.print("Pick a number 1-4: ");
            choice = input.nextInt();
        }
        switch (choice) {
	case 1:
	    System.out.println("You selected Moon, your weight on Moon is: ");
	    System.out.println(weight * (moon / earth) + " Lbs");
	    break;
	case 2:
	    System.out.println("You selected Mercury, your weight on Mercury is: ");
	    System.out.println(weight * (mercury / earth) + " Lbs");
	    break;
	case 3:
	    System.out.println("You selected Venus, your weight on Venus is: ");
	    System.out.println(weight * (venus / earth) + " Lbs");
	    break;
	case 4:
	    System.out.println("You selected Jupiter, your weight on Jupiter is: ");
	    System.out.println(weight * (jupiter / earth) + " Lbs");
	    break;
        }

        System.out.println("Thank you for using the Planetary Weight Calculator");
        System.out.println("Hope you will use it again! ");

    }

}
