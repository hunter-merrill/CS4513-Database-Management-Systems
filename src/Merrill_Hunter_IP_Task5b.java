import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.*;
import java.util.Scanner;
import java.util.Properties;

public class Merrill_Hunter_IP_Task5b {

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
                System.out.println("\nWELCOME TO THE NATIONAL PARK SERVICE SYSTEM DATABASE");

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
                    case 2 -> runQuery2(conn, in);
                    case 3 -> insertRangerTeam(conn, in);
                    case 4 -> runQuery4(conn, in);
                    case 5 -> runQuery5(conn, in);
                    case 6 -> insertReport(conn, in);
                    case 7 -> insertProgram(conn, in);
                    case 8 -> retrieveEmergencyContacts(conn, in);
                    case 9 -> retrieveProgramVisitors(conn, in);
                    case 10 -> retrieveProgramsAfterDate(conn, in);
                    case 11 -> retrieveAnonymousDonations(conn, in);
                    case 12 -> retrieveTeamDetails(conn, in);
                    case 13 -> retrieveAllIndividuals(conn, in);
                    case 14 -> updateResearcherSalary(conn, in);
                    case 15 -> deleteInactiveVisitors(conn, in);
                    case 16 -> importTeamsFromFile(conn, in);
                    case 17 -> exportMailingListToFile(conn, in);
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

        // Only proceed if insertion successful
        if (visitor_id != null) {
            enrollVisitorInProgram(conn, in, visitor_id);
            insertPhoneNumbers(conn, in, visitor_id);
            insertEmails(conn, in, visitor_id);
            insertEmergencyContacts(conn, in, visitor_id);
        }
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
        String[] params = { "park_name", "program_name", "visit_date", "accessibility_needs (optional)" };
        String[] inputs = readParams(in, params);

        // Enrollment parameters
        String park_name = inputs[0];
        String program_name = inputs[1];
        java.sql.Date visit_date = java.sql.Date.valueOf(inputs[2]);
        String accessibility_needs = inputs[3].isEmpty() ? null : inputs[3]; // Convert "" --> null

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

    // Query 2 commands
    private static void runQuery2(Connection conn, Scanner in) {
        // Calls helper sub-queries to insert Ranger and assign them to a team

        String ranger_id = insertRanger(conn, in); // Insert individual + subtype) and get id

        // Only proceed if insertion successful
        if (ranger_id != null) {
            assignRangerToTeam(conn, in, ranger_id);
            insertPhoneNumbers(conn, in, ranger_id);
            insertEmails(conn, in, ranger_id);
            insertEmergencyContacts(conn, in, ranger_id);
            insertCertifications(conn, in, ranger_id);
        }
    }

    private static String insertRanger(Connection conn, Scanner in) {
        // Calls SP_InsertRanger and returns ranger_id

        // Output parameter list & read in input
        String[] params = {
                "ranger_id", "first_name", "middle_initial", "last_name", "date_of_birth",
                "gender", "street", "city", "us_state", "zip", "is_subscribed_to_newsletter"
        };
        String[] inputs = readParams(in, params);

        // Insertion params
        String ranger_id = inputs[0];
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

        // Try SP_InsertRanger
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_InsertRanger(?,?,?,?,?,?,?,?,?,?,?)}")) {
            cs.setString("ranger_id", ranger_id);
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
            System.out.println("Successfully inserted ranger.");
            return ranger_id;
        } catch (SQLException e) {
            System.err.println("Query 2 insertion failed:");
            printSqlException(e);
            return null;
        }
    }

    private static void assignRangerToTeam(Connection conn, Scanner in, String ranger_id) {
        // Calls SP_AssignRangerToTeam

        // Output parameter list & read in input
        String[] params = { "team_id", "start_date" };
        String[] inputs = readParams(in, params);

        // Assignment parameters
        String team_id = inputs[0];
        java.sql.Date start_date = java.sql.Date.valueOf(inputs[1]);

        // Try SP_AssignRangerToTeam
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_AssignRangerToTeam(?,?,?,?)}")) {
            cs.setString("ranger_id", ranger_id);
            cs.setString("team_id", team_id);
            cs.setDate("start_date", start_date);
            cs.setNString("assignment_status", "active");

            cs.execute();
            System.out.println("Successfully assigned ranger to team.");
        } catch (SQLException e) {
            System.err.println("Query 2 assignment failed:");
            printSqlException(e);
        }
    }

    private static void insertCertifications(Connection conn, Scanner in, String ranger_id) {
        // Read in certifications until user indicates finish

        while (true) {
            // Read certification name
            System.out.print("\nEnter certification name or type 'n' to stop: ");
            String certification = in.nextLine().trim();

            // Check if stopped
            if (certification.equalsIgnoreCase("n") || certification.isEmpty()) {
                break;
            }

            // Try SP_CertifyRanger
            try (CallableStatement cs = conn.prepareCall("{ CALL npss.SP_CertifyRanger(?,?)}")) {
                cs.setString("ranger_id", ranger_id);
                cs.setNString("certification", certification);
                cs.execute();
                System.out.println("Successfully added certification.");

            } catch (SQLException e) {
                System.err.println("Failed to add certification: " + e.getMessage());
            }
        }
    }

    // Query 3 commands
    private static String insertRangerTeam(Connection conn, Scanner in) {
        // Calls SP_InsertRangerTeam and returns team_id

        // Output parameter list & read in input
        String[] params = {
                "team_id", "leader_id", "focus_area", "formation_date"
        };
        String[] inputs = readParams(in, params);

        // Inerstion params
        String team_id = inputs[0];
        String leader_id = inputs[1];
        String focus_area = inputs[2];
        java.sql.Date formation_date = java.sql.Date.valueOf(inputs[3]);

        // Try SP_InsertRangerTeam
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_InsertRangerTeam(?,?,?,?)}")) {
            cs.setString("team_id", team_id);
            cs.setString("leader_id", leader_id);
            cs.setNString("focus_area", focus_area);
            cs.setDate("formation_date", formation_date);

            cs.execute();
            System.out.println(
                    "Successfully inserted team " + team_id + " and assigned leader " + leader_id + ".");
            return team_id;
        } catch (SQLException e) {
            System.err.println("Query 3 Team insertion failed:");
            printSqlException(e);
            return null;
        }
    }

    // Query 4 commands
    private static void runQuery4(Connection conn, Scanner in) {
        // Calls helper to handle either card or check donation insertion.

        // Get donor ID
        System.out.print("Enter existing donor's ID: ");
        String donor_id = in.nextLine().trim();

        // Get donation type
        System.out.print("Donation type: ");
        String type = in.nextLine().trim().toLowerCase();

        // Call insertion helper
        switch (type) {
            case "card":
                insertCardDonation(conn, in, donor_id);
                break;
            case "check":
                insertCheckDonation(conn, in, donor_id);
                break;
            default:
                System.out.println("Invalid donation type entered. Please use 'Card' or 'Check'.");
                break;
        }
    }

    private static void insertCardDonation(Connection conn, Scanner in, String donor_id) {
        // Calls SP_InsertCardDonation

        // Output parameter list & read in input
        String[] params = {
                "park_name", "donation_date", "amount", "campaign_name (optional)",
                "card_type", "card_last_four_digits", "card_expiration_date"
        };
        String[] inputs = readParams(in, params);

        // Insertion params
        String park_name = inputs[0];
        java.sql.Date donation_date = java.sql.Date.valueOf(inputs[1]);
        int amount = Integer.parseInt(inputs[2]);
        String campaign_name = inputs[3].isEmpty() ? null : inputs[3]; // Convert "" --> null
        String card_type = inputs[4];
        String card_last_four_digits = inputs[5];
        java.sql.Date card_expiration_date = java.sql.Date.valueOf(inputs[6]);

        // Try SP_InsertCardDonation
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_InsertCardDonation(?,?,?,?,?,?,?,?)}")) {
            cs.setNString("park_name", park_name);
            cs.setString("donor_id", donor_id);
            cs.setDate("donation_date", donation_date);
            cs.setInt("amount", amount);
            cs.setNString("campaign_name", campaign_name);
            cs.setNString("card_type", card_type);
            cs.setString("card_last_four_digits", card_last_four_digits);
            cs.setDate("card_expiration_date", card_expiration_date);

            cs.execute();
            System.out.println("Successfully inserted Card Donation from Donor " + donor_id + ".");
        } catch (SQLException e) {
            System.err.println("Query 4 Card Donation insertion failed:");
            printSqlException(e);
        }
    }

    private static void insertCheckDonation(Connection conn, Scanner in, String donor_id) {
        // Calls SP_InsertCheckDonation

        // Output parameter list & read in input
        String[] params = {
                "park_name", "donation_date", "amount", "campaign_name (optional)",
                "check_number"
        };
        String[] inputs = readParams(in, params);

        // Insertion params
        String park_name = inputs[0];
        java.sql.Date donation_date = java.sql.Date.valueOf(inputs[1]);
        int amount = Integer.parseInt(inputs[2]);
        String campaign_name = inputs[3].isEmpty() ? null : inputs[3]; // Convert "" --> null
        int check_number = Integer.parseInt(inputs[4]);

        // Try SP_InsertCheckDonation
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_InsertCheckDonation(?,?,?,?,?,?)}")) {
            cs.setNString("park_name", park_name);
            cs.setString("donor_id", donor_id);
            cs.setDate("donation_date", donation_date);
            cs.setInt("amount", amount);
            cs.setNString("campaign_name", campaign_name);
            cs.setInt("check_number", check_number);

            cs.execute();
            System.out.println("Successfully inserted Check Donation from Donor " + donor_id + ".");
        } catch (SQLException e) {
            System.err.println("Query 4 Check Donation insertion failed:");
            printSqlException(e);
        }
    }

    // Query 5 commands
    private static void runQuery5(Connection conn, Scanner in) {
        // Calls helper to insert the Researcher and associate them with teams

        String researcher_id = insertResearcher(conn, in);

        // Only proceed if researcher successfully created
        if (researcher_id != null) {
            associateResearcherWithTeam(conn, in, researcher_id);
            insertPhoneNumbers(conn, in, researcher_id);
            insertEmails(conn, in, researcher_id);
            insertEmergencyContacts(conn, in, researcher_id);
        }
    }

    private static String insertResearcher(Connection conn, Scanner in) {
        // Calls SP_InsertResearcher and returns researcher_id

        // Output parameter list & read in input
        String[] params = {
                "researcher_id", "first_name", "middle_initial", "last_name", "date_of_birth",
                "gender", "street", "city", "us_state", "zip", "is_subscribed_to_newsletter",
                "research_field", "hire_date", "salary"
        };
        String[] inputs = readParams(in, params);

        // Insertion parameters
        String researcher_id = inputs[0];
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
        String research_field = inputs[11];
        java.sql.Date hire_date = java.sql.Date.valueOf(inputs[12]);
        int salary = Integer.parseInt(inputs[13]);

        // Try SP_InsertResearcher
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_InsertResearcher(?,?,?,?,?,?,?,?,?,?,?,?,?,?)}")) {
            cs.setString("researcher_id", researcher_id);
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
            cs.setNString("research_field", research_field);
            cs.setDate("hire_date", hire_date);
            cs.setInt("salary", salary);

            cs.execute();
            System.out.println("Successfully inserted Researcher " + researcher_id + ".");
            return researcher_id;
        } catch (SQLException e) {
            System.err.println("Query 5 Researcher insertion failed:");
            printSqlException(e);
            return null;
        }
    }

    private static void associateResearcherWithTeam(Connection conn, Scanner in, String researcher_id) {
        // Calls SP_AssociateResearcherWithTeam for one or more teams

        while (true) {
            System.out
                    .print("Enter Team ID to associate Researcher " + researcher_id + " with or type 'n' to stop: ");
            String team_id = in.nextLine().trim();

            if (team_id.equalsIgnoreCase("n") || team_id.isEmpty()) {
                break;
            }

            // Try SP_AssociateResearcherWithTeam
            try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_AssociateResearcherWithTeam(?,?)}")) {
                cs.setString("researcher_id", researcher_id);
                cs.setString("team_id", team_id);

                cs.execute();
                System.out
                        .println("Successfully associated researcher " + researcher_id + " with team " + team_id + ".");
            } catch (SQLException e) {
                System.err.println("Failed to associate team " + team_id + ":");
                printSqlException(e);
            }
        }
    }

    // Query 6 commands
    private static void insertReport(Connection conn, Scanner in) {
        // Calls SP_InsertReport

        // Output parameter list & read in input
        String[] params = {
                "team_id", "report_date", "researcher_id", "summary_of_activities"
        };
        String[] inputs = readParams(in, params);

        // Insertion params
        String team_id = inputs[0];
        java.sql.Date report_date = java.sql.Date.valueOf(inputs[1]);
        String researcher_id = inputs[2];
        String summary_of_activities = inputs[3];

        // Try SP_InsertReport
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_InsertReport(?,?,?,?)}")) {
            cs.setString("team_id", team_id);
            cs.setDate("report_date", report_date);
            cs.setString("researcher_id", researcher_id);
            cs.setNString("summary_of_activities", summary_of_activities);

            cs.execute();
            System.out.println(
                    "Successfully inserted report from team " + team_id + " to researcher " + researcher_id + ".");
        } catch (SQLException e) {
            System.err.println("Query 6 Report insertion failed:");
            printSqlException(e);
        }
    }

    // Query 7 commands
    private static void insertProgram(Connection conn, Scanner in) {
        // Calls SP_InsertProgram

        // Output parameter list & read in input
        String[] params = {
                "program_name", "park_name", "program_type", "start_date", "duration"
        };
        String[] inputs = readParams(in, params);

        // Insertion params
        String program_name = inputs[0];
        String park_name = inputs[1];
        String program_type = inputs[2];

        java.sql.Date start_date = java.sql.Date.valueOf(inputs[3]);
        java.sql.Time duration = java.sql.Time.valueOf(inputs[4]);

        // Try SP_InsertProgram
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_InsertProgram(?,?,?,?,?)}")) {
            cs.setNString("program_name", program_name);
            cs.setNString("park_name", park_name);
            cs.setNString("program_type", program_type);
            cs.setDate("start_date", start_date);
            cs.setTime("duration", duration);

            cs.execute();
            System.out.println("Successfully inserted program '" + program_name + "' for park " + park_name + ".");
        } catch (SQLException e) {
            System.err.println("Query 7 Program insertion failed:");
            printSqlException(e);
        }
    }

    // Query 8 commands
    private static void retrieveEmergencyContacts(Connection conn, Scanner in) {
        // Calls SP_RetrieveEmergencyContacts and prints the results.

        // Output parameter list & read in input
        String[] params = { "individual_id" };
        String[] inputs = readParams(in, params);
        String individual_id = inputs[0];

        // Try SP_RetrieveEmergencyContacts
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_RetrieveEmergencyContacts(?)}")) {
            cs.setString("individual_id", individual_id);

            try (ResultSet rs = cs.executeQuery()) {

                // Check if any results were returned
                if (!rs.isBeforeFirst()) {
                    System.out.println("No emergency contacts found for this individual.");
                    return;
                }

                // Header
                System.out.printf("%-25s | %-15s | %-15s\n", "Contact Name", "Relationship", "Phone Number");
                System.out.println("---------------------------------------------------------------------");

                // Print results
                while (rs.next()) {
                    String contact_name = rs.getString("contact_name");
                    String relationship = rs.getString("relationship");
                    String phone_number = rs.getString("phone_number");
                    System.out.printf("%-25s | %-15s | %-15s\n", contact_name, relationship, phone_number);
                }
            }
        } catch (SQLException e) {
            System.err.println("Query 8 retrieval failed:");
            printSqlException(e);
        }
    }

    // Query 9 commands
    private static void retrieveProgramVisitors(Connection conn, Scanner in) {
        // Calls SP_RetrieveProgramVisitors and prints the results.

        // Output parameter list & read in input
        String[] params = { "park_name", "program_name" };
        String[] inputs = readParams(in, params);
        String park_name = inputs[0];
        String program_name = inputs[1];

        // Try SP_RetrieveProgramVisitors
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_RetrieveProgramVisitors(?,?)}")) {
            cs.setNString("park_name", park_name);
            cs.setNString("program_name", program_name);

            try (ResultSet rs = cs.executeQuery()) {
                System.out
                        .println("\nEnrolled visitors for " + program_name + " at " + park_name + ".");

                // Check if any results were returned
                if (!rs.isBeforeFirst()) {
                    System.out.println("No visitors found enrolled in this program.");
                    return;
                }

                // Print Header
                System.out.printf("%-15s | %-50s\n", "Visitor ID", "Accessibility Needs");
                System.out.println("---------------------------------------------------------------------");

                // Print results
                while (rs.next()) {
                    String visitorId = rs.getString("visitor_id");
                    String accessibilityNeeds = rs.getString("accessibility_needs");
                    System.out.printf("%-15s | %-50s\n", visitorId, accessibilityNeeds);
                }
            }
        } catch (SQLException e) {
            System.err.println("Query 9 retrieval failed:");
            printSqlException(e);
        }
    }

    // Query 10 commands
    private static void retrieveProgramsAfterDate(Connection conn, Scanner in) {
        // Calls SP_RetrieveProgramsAfterDate and prints the results.

        // Output parameter list & read in input
        String[] params = { "park_name", "start_after" };
        String[] inputs = readParams(in, params);
        String park_name = inputs[0];
        java.sql.Date start_after = java.sql.Date.valueOf(inputs[1]);

        // Try SP_RetrieveProgramsAfterDate
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_RetrieveProgramsAfterDate(?,?)}")) {
            // Bind the program identifiers
            cs.setNString("park_name", park_name);
            cs.setDate("start_after", start_after);

            try (ResultSet rs = cs.executeQuery()) {

                // Check if any results were returned
                if (!rs.isBeforeFirst()) {
                    System.out.println("No programs found matching the criteria.");
                    return;
                }

                // Print Header
                System.out.printf("%-25s | %-15s | %-15s | %-10s\n",
                        "Program Name", "Type", "Start Date", "Duration");
                System.out.println("---------------------------------------------------------------------");

                // Print results
                while (rs.next()) {
                    String programName = rs.getString("program_name");
                    String programType = rs.getString("program_type");
                    java.sql.Date startDate = rs.getDate("start_date");
                    java.sql.Time duration = rs.getTime("duration");
                    System.out.printf("%-25s | %-15s | %-15s | %-10s\n",
                            programName, programType, startDate.toString(), duration.toString());
                }
            }
        } catch (SQLException e) {
            System.err.println("Query 10 retrieval failed:");
            printSqlException(e);
        }
    }

    // Query 11 commands
    private static void retrieveAnonymousDonations(Connection conn, Scanner in) {
        // Calls SP_RetrieveAnonymousDonations and prints the results.

        // Output parameter list & read in input
        System.out.print("Enter target year: ");
        int donation_year = readInt(in);
        System.out.print("Enter target month: ");
        int donation_month = readInt(in);

        // Try SP_RetrieveAnonymousDonations
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_RetrieveAnonymousDonations(?,?)}")) {
            cs.setInt("donation_year", donation_year);
            cs.setInt("donation_month", donation_month);

            try (ResultSet rs = cs.executeQuery()) {

                // Check if any results were returned
                if (!rs.isBeforeFirst()) {
                    System.out.println("No anonymous donations found matching the criteria.");
                    return;
                }

                // Print Header
                System.out.printf("%-15s | %-15s | %-15s\n",
                        "Donor ID", "Total Amount", "Average Amount");
                System.out.println("---------------------------------------------------------------------");

                // Print results
                while (rs.next()) {
                    String donorId = rs.getString("donor_id");
                    double totalAmount = rs.getDouble("total");
                    double averageAmount = rs.getDouble("average");
                    System.out.printf("%-15s | $%-14.2f | $%-14.2f\n",
                            donorId, totalAmount, averageAmount);
                }
            }
        } catch (SQLException e) {
            System.err.println("Query 11 retrieval failed:");
            printSqlException(e);
        }
    }

    // Query 12 commands
    private static void retrieveTeamDetails(Connection conn, Scanner in) {
        // Calls SP_RetrieveTeam and prints the results.

        // Output parameter list & read in input
        String[] params = { "team_id" };
        String[] inputs = readParams(in, params);
        String team_id = inputs[0];

        // Try SP_RetrieveTeam
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_RetrieveTeam(?)}")) {
            cs.setString("team_id", team_id);

            try (ResultSet rs = cs.executeQuery()) {

                // Check if any results were returned
                if (!rs.isBeforeFirst()) {
                    System.out.println("No rangers found for this team, or team does not exist.");
                    return;
                }

                // Print Header
                System.out.printf("%-15s | %-20s | %-10s | %-10s | %-50s\n",
                        "Ranger ID", "Name", "Role", "Yrs. Service", "Certifications");
                System.out.println(
                        "-----------------------------------------------------------------------------------------------------------------");

                // Print results
                while (rs.next()) {
                    String rangerId = rs.getString("ranger_id");
                    String firstName = rs.getString("first_name");
                    String lastName = rs.getString("last_name");
                    String fullName = firstName + " " + lastName;
                    String teamRole = rs.getString("team_role");
                    int yearsOfService = rs.getInt("years_of_service");
                    String certifications = rs.getString("certifications");

                    // null/empty certifications
                    if (certifications == null) {
                        certifications = "None";
                    }

                    System.out.printf("%-15s | %-20s | %-10s | %-10d | %-50s\n",
                            rangerId, fullName, teamRole, yearsOfService, certifications);
                }
            }
        } catch (SQLException e) {
            System.err.println("Query 12 retrieval failed:");
            printSqlException(e);
        }
    }

    // Query 13 commands
    private static void retrieveAllIndividuals(Connection conn, Scanner in) {
        // Calls SP_RetrieveAllIndividuals and prints the results.

        // Try SP_RetrieveAllIndividuals
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_RetrieveAllIndividuals}")) {

            try (ResultSet rs = cs.executeQuery()) {

                // Check if any results were returned
                if (!rs.isBeforeFirst()) {
                    System.out.println("No individuals found in the database.");
                    return;
                }

                // Print Header
                System.out.printf("%-15s | %-25s | %-15s | %-15s | %-35s\n",
                        "ID", "Full Name", "Newsletter", "Phones", "Emails");
                System.out.println(
                        "--------------------------------------------------------------------------------------------------------------------------------");

                // Print results
                while (rs.next()) {
                    String id = rs.getString("id");
                    String firstName = rs.getString("first_name");
                    String middleInitial = rs.getString("middle_initial");
                    String lastName = rs.getString("last_name");

                    // full name for display
                    String fullName = firstName + " " + (middleInitial != null ? middleInitial + " " : "") + lastName;

                    boolean isSubscribed = rs.getBoolean("is_subscribed_to_newsletter");
                    String phoneNumbers = rs.getString("phone_numbers");
                    String emailAddresses = rs.getString("email_addresses");

                    // Clean up null/empty strings
                    if (phoneNumbers == null)
                        phoneNumbers = "None";
                    if (emailAddresses == null)
                        emailAddresses = "None";

                    System.out.printf("%-15s | %-25s | %-15s | %-15s | %-35s\n",
                            id,
                            fullName,
                            isSubscribed ? "YES" : "NO",
                            phoneNumbers,
                            emailAddresses);
                }
            }
        } catch (SQLException e) {
            System.err.println("Query 13 retrieval failed:");
            printSqlException(e);
        }
    }

    // Query 14 commands
    private static void updateResearcherSalary(Connection conn, Scanner in) {
        // Calls SP_UpdateResearcherSalary

        // Try SP_UpdateResearcherSalary
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_UpdateResearcherSalaries}")) {
            cs.execute();
            System.out.println("Successfully updated salaries.");

        } catch (SQLException e) {
            System.err.println("Query 14 salary update failed:");
            printSqlException(e);
        }
    }

    // Query 15 commands
    private static void deleteInactiveVisitors(Connection conn, Scanner in) {
        // Calls SP_DeleteInactiveVisitors

        // Try SP_DeleteInactiveVisitors
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_DeleteInactiveVisitors}")) {
            int affectedRows = cs.executeUpdate();
            if (affectedRows > 0) {
                System.out.println("Successfully deleted " + affectedRows + " inactive visitors.");
            } else {
                System.out.println("No inactive visitors found.");
            }

        } catch (SQLException e) {
            System.err.println("Query 15 deletion failed:");
            printSqlException(e);
        }
    }

    // Query 16 commands
    private static void importTeamsFromFile(Connection conn, Scanner in) {
        System.out.print("Enter input file name: ");
        String fileName = in.nextLine().trim();

        int processed = 0;

        // Use an external Scanner to read the file
        try (Scanner fileScanner = new Scanner(new File(fileName))) {

            // Loop through each line in the input file
            while (fileScanner.hasNextLine()) {
                String line = fileScanner.nextLine();
                if (line.trim().isEmpty())
                    continue; // Skip empty lines

                processed++;
                String[] fields = line.split(","); // CSV format team_id, leader_id, focus_area, formation_date

                // Insertion params
                String team_id = fields[0].trim();
                String leader_id = fields[1].trim();
                String focus_area = fields[2].trim();
                java.sql.Date formation_date = java.sql.Date.valueOf(fields[3].trim());

                // Try SP_InsertRangerTeam
                try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_InsertRangerTeam(?,?,?,?)}")) {
                    cs.setString("team_id", team_id);
                    cs.setString("leader_id", leader_id);
                    cs.setNString("focus_area", focus_area);
                    cs.setDate("formation_date", formation_date);

                    cs.execute();
                } catch (SQLException e) {
                    System.err.printf("Database Error on line %d ('%s'): Failed to insert team %s.\n", processed,
                            line, team_id);
                    printSqlException(e);
                }
            }

            System.out.printf("Successfully imported %d teams.\n", processed);

        } catch (FileNotFoundException e) {
            System.err.println("File not found: " + fileName);
        }
    }

    // Query 17 commands
    private static void exportMailingListToFile(Connection conn, Scanner in) {
        System.out.print("Enter the output file name: ");
        String fileName = in.nextLine().trim();

        int exported = 0;

        // Try SP_RetrieveMailingList
        try (CallableStatement cs = conn.prepareCall("{CALL npss.SP_RetrieveMailingList}")) {
            try (ResultSet rs = cs.executeQuery()) { // Collect results
                try (FileWriter writer = new FileWriter(fileName)) { // Open file

                    // Header
                    writer.write("ID,FirstName,LastName,Street,City,State,Zip\n");

                    // Iterate through results & write to file
                    while (rs.next()) {
                        String id = rs.getString("id");
                        String first_name = rs.getString("first_name");
                        String last_name = rs.getString("last_name");
                        String street = rs.getString("street");
                        String city = rs.getString("city");
                        String us_state = rs.getString("us_state");
                        String zip = rs.getString("zip");

                        writer.write(id + "," + first_name + "," + last_name + ","
                                + street + "," + city + "," + us_state + "," + zip + "\n");
                        exported++;
                    }

                    System.out.println("Successfully exported " + exported + " records to " + fileName);

                } catch (IOException e) {
                    System.err.println("Error writing to file " + fileName + ": " + e.getMessage());
                }
            }
        } catch (SQLException e) {
            System.err.println("Query 17 retrieval from database failed:");
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
            System.out.print("Enter " + params[i] + ": ");
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