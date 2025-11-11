import java.sql.*;
import java.util.Scanner;
import java.util.Properties;

public class NPSS {

    // Connection params for my Azure db
    private static final String URL = "jdbc:sqlserver://hunter-merrill-dbms-fall-2025.database.windows.net:1433;" +
            "database=HW2;" +
            "encrypt=true;" +
            "trustServerCertificate=false;" +
            "hostNameInCertificate=*.database.windows.net;" +
            "loginTimeout=30";
    private static final String USER = "CloudSA639c23c6";
    private static final String PASS = "DbpxRRcGfary2iT";

    // Driver program that listens & reacts to user input
    public static void main(String[] args) {
        // Load SQL Server driver
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            System.out.println("JDBC driver loaded.");
        } catch (ClassNotFoundException e) {
            System.err.println("SQL Server JDBC driver not found on classpath.");
            e.printStackTrace();
            return;
        }

        // Connect once and run menu until user quits
        try (Connection conn = DriverManager.getConnection(URL, USER, PASS);
                Scanner in = new Scanner(System.in)) {
            System.out.println("Connected to Azure SQL.");

            int choice;
            do {
                System.out.println("WELCOME TO THE NATIONAL PARK SERVICE SYSTEM DATABASE");

                // Menu descriptions
                System.out.println(
                        "(1) Insert a new visitor into the database and associate them with one or more park programs");
                System.out.println(
                        "(2) Insert a new ranger into the database and assign them to a ranger team");
                System.out.println("(3) Insert a new ranger team into the database and set its leader");
                System.out.println("(4) Insert a new donation from a donor");
                System.out.println(
                        "(5) Insert a new researcher into the database and associate them with one or more ranger teams");
                System.out.println("(6) Insert a report submitted by a ranger team to a researcher");
                System.out.println(
                        "(7) Insert a new park program into the database for a specific park");
                System.out.println(
                        "(8) Retrieve the names and contact information of all emergency contacts for a specific person");
                System.out.println(
                        "(9) Retrieve the list of visitors enrolled in a specific park program, including their accessibility needs");
                System.out.println(
                        "(10) Retrieve all park programs for a specific park that started after a given date");
                System.out.println(
                        "(11) Retrieve the total and average donation amount received in a month from all anonymous donors. The result must be sorted by total amount of the donation in descending order");
                System.out.println(
                        "(12) Retrieve the list of rangers in a team, including their certifications, years of service and their role in the team (leader or member)");
                System.out.println(
                        "(13) Retrieve the names, IDs, contact information, and newsletter subscription status of all individuals in the database");
                System.out.println(
                        "(14) Update the salary of researchers overseeing more than one ranger team by a 3% increase");
                System.out.println(
                        "(15) Delete visitors who have not enrolled in any park programs and whose park passes have expired");
                System.out.println(
                        "(16) Import: enter new teams from a data file until the file is empty (the user must be asked to enter the input file name)");
                System.out.println(
                        "(17) Export: Retrieve names and mailing addresses of all people on the mailing list and output them to a data file instead of screen (the user must be asked to enter the output file name)");
                System.out.println("(18) Quit");

                System.out.print("Enter your choice: ");
                choice = readInt(in);

                // Call query function based on choice
                switch (choice) {
                    case 1 -> runQuery1(conn, in);
                    // case 2 -> runOption2(conn, in);
                    // case 3 -> listPilots(conn);
                    case 18 -> System.out.println("Thank you. Goodbye.");
                    default -> System.out.println("Invalid choice. Try again.");
                }
            } while (choice != 18);

        } catch (SQLException e) {
            System.err.println("Database error.");
            printSqlException(e);
        }
    }

    // Query 1 commands
    private static void runQuery1(Connection conn, Scanner in) {
        // Calls helper sub-queries

        String visitor_id = insertVisitor(conn, in);
        enrollVisitorInProgram(conn, in, visitor_id);
        insertPhoneNumbers(conn, in, visitor_id);
        insertEmails(conn, in, visitor_id);
        insertEmergencyContacts(conn, in, visitor_id);
    }

    private static String insertVisitor(Connection conn, Scanner in) {
        // Calls SP_InsertVisitor and returns visitor_id

        // Output parameter list & read in input
        String[] params = { "visitor_id", "first_name", "middle_initial", "last_name", "date_of_birth", "gender",
                "street", "city", "us_state", "zip", "is_subscribed_to_newsletter" };
        String[] inputs = readParams(in, params);

        // Extract properly-typed parameters from input
        // Insertion parameters
        String visitor_id = inputs[0];
        String first_name = inputs[1];
        String middle_initial = inputs[2];
        String last_name = inputs[3];
        java.sql.Date date_of_birth = java.sql.Date.valueOf(inputs[4]);
        String gender = inputs[5];
        String street = inputs[6];
        String city = inputs[7];
        String us_state = inputs[8];
        String zip = inputs[9];
        boolean is_subscribed_to_newsletter = Boolean.valueOf(inputs[10]);

        // Try SP_InsertVisitor
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_InsertVisitor(?,?,?,?,?,?,?,?,?,?,?)}")) {
            cs.setString("visitor_id", visitor_id);
            cs.setNString("first_name", first_name);
            cs.setNString("middle_initial", middle_initial);
            cs.setNString("last_name", last_name);
            cs.setDate("date_of_birth", date_of_birth);
            cs.setString("gender", gender);
            cs.setNString("street", street);
            cs.setNString("city", city);
            cs.setString("us_state", us_state);
            cs.setString("zip", zip);
            cs.setBoolean("is_subscribed_to_newsletter", is_subscribed_to_newsletter);

            cs.execute();
            System.out.println("Successfully inserted visitor.");
        } catch (SQLException e) {
            System.err.println("Query 1 insertion failed:");
            printSqlException(e);
        }

        return visitor_id;
    }

    private static void enrollVisitorInProgram(Connection conn, Scanner in, String visitor_id) {
        // Calls SP_EnrollVisitorInProgram

        // Output parameter list & read in input
        String[] params = { "park_name", "program_name", "visit_date", "accessibility_needs" };
        String[] inputs = readParams(in, params);

        // Enrollment parameters
        String park_name = inputs[0];
        String program_name = inputs[1];
        java.sql.Date visit_date = java.sql.Date.valueOf(inputs[2]);
        String accessibility_needs = inputs[3];

        // Try SP_EnrollVisitorInProgram
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_EnrollVisitorInProgram(?,?,?,?,?)}")) {
            cs.setString("visitor_id", visitor_id);
            cs.setNString("park_name", park_name);
            cs.setNString("program_name", program_name);
            cs.setDate("visit_date", visit_date);
            cs.setNString("accessibility_needs", accessibility_needs);

            cs.execute();
            System.out.println("Successfully enrolled visitor.");
        } catch (SQLException e) {
            System.err.println("Query 1 enrollment failed:");
            printSqlException(e);
        }
    }

    // Insertion helpers
    private static void insertPhoneNumbers(Connection conn, Scanner in, String individual_id) {
        // Read in phone numbers until user indicates finish

        while (true) {
            // Reead number
            System.out.print("\nEnter phone number or type 'n' to stop: ");
            String phone_number = in.nextLine().trim();

            // Check if stopped
            if (phone_number.equalsIgnoreCase("n") || phone_number.isEmpty()) {
                break;
            }

            // Try SP_InsertPhoneNumber
            try (CallableStatement cs = conn.prepareCall("{ CALL npss.SP_InsertPhoneNumber(?,?)}")) {
                cs.setString("individual_id", individual_id);
                cs.setString("phone_number", phone_number);
                cs.execute();
                System.out.println("Successfully added phone number.");

            } catch (SQLException e) {
                System.err.println("Failed to add phone number: " + e.getMessage());
            }
        }
    }

    private static void insertEmails(Connection conn, Scanner in, String individual_id) {
        // Read in emails until user indicates finish

        while (true) {
            // Read address
            System.out.print("\nEnter email address or type 'n' to stop: ");
            String email_address = in.nextLine().trim();

            // Check if stopped
            if (email_address.equalsIgnoreCase("n") || email_address.isEmpty()) {
                break;
            }

            // Try SP_InsertEmailAddress
            try (CallableStatement cs = conn.prepareCall("{ CALL npss.SP_InsertEmailAddress(?,?)}")) {
                cs.setString("individual_id", individual_id);
                cs.setString("email_address", email_address);
                cs.execute();
                System.out.println("Successfully added email address.");

            } catch (SQLException e) {
                System.err.println("Failed to add email: " + e.getMessage());
            }
        }
    }

    private static void insertEmergencyContacts(Connection conn, Scanner in, String individual_id) {
        // Read in contacts until user indicates finish

        while (true) {
            // Read contact
            System.out.print("\nAdding emergency contacts. Press enter to continue or type 'n' to stop: ");
            String prompt = in.nextLine().trim();

            // Check if stopped
            if (prompt.equalsIgnoreCase("n")) {
                break;
            }

            // Output parameter list & read in input
            String[] params = { "first_name", "middle_initial", "last_name", "relationship", "phone_number" };
            String[] inputs = readParams(in, params);

            // Contact parameters
            String first_name = inputs[0];
            String middle_initial = inputs[1];
            String last_name = inputs[2];
            String relationship = inputs[3];
            String phone_number = inputs[4];

            try (CallableStatement cs = conn.prepareCall("{ CALL npss.SP_InsertEmergencyContact(?,?,?,?,?,?)}")) {
                cs.setString("individual_id", individual_id);
                cs.setNString("first_name", first_name);
                cs.setNString("middle_initial", middle_initial);
                cs.setNString("last_name", last_name);
                cs.setNString("relationship", relationship);
                cs.setString("phone_number", phone_number);

                cs.execute();
                System.out.println("Successfully added emergency contact.");

            } catch (SQLException e) {
                System.err.println("Failed to add emergency contact: " + e.getMessage());
            }
        }
    }

    // Menu helpers
    private static int readInt(Scanner in) {
        while (!in.hasNextInt()) {
            in.next();
            System.out.print("Please enter a valid integer: ");
        }
        int v = in.nextInt();
        in.nextLine(); // consume newline
        return v;
    }

    private static String[] readParams(Scanner in, String[] params) {
        // Print parameter list
        System.out.println("\nParameters: " + String.join(", ", params));

        // Prompt input for each parameter
        String[] inputs = new String[params.length];
        for (int i = 0; i < params.length; i++) {
            System.out.println("Enter " + params[i] + ":");
            inputs[i] = in.nextLine().trim();
        }

        // Return list of inputs
        return inputs;
    }

    private static void printSqlException(SQLException e) {
        System.err.printf("SQLState=%s ErrorCode=%d Message=%s%n",
                e.getSQLState(), e.getErrorCode(), e.getMessage());
        Throwable t = e.getCause();
        while (t != null) {
            System.err.println("Cause: " + t);
            t = t.getCause();
        }
    }
}