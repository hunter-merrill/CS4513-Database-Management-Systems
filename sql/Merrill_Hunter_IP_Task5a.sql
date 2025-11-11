-- Query 1: Insert a new visitor into the database and associate them with one or more park programs (10/day).
CREATE OR

ALTER PROCEDURE npss.SP_InsertVisitor (
    @visitor_id VARCHAR(20),
    @first_name NVARCHAR(127),
    @middle_initial NCHAR,
    @last_name NVARCHAR(127),
    @date_of_birth DATE,
    @gender CHAR(1),
    @street NVARCHAR(127),
    @city NVARCHAR(127),
    @us_state CHAR(2),
    @zip VARCHAR(13),
    @is_subscribed_to_newsletter BIT
    )
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRANSACTION

    -- Try to insert visitor
    BEGIN TRY
        -- Insert into supertype
        INSERT INTO npss.individuals (
            id,
            first_name,
            middle_initial,
            last_name,
            date_of_birth,
            gender,
            street,
            city,
            us_state,
            zip,
            is_subscribed_to_newsletter
            )
        VALUES (
            @visitor_id,
            @first_name,
            @middle_initial,
            @last_name,
            @date_of_birth,
            @gender,
            @street,
            @city,
            @us_state,
            @zip,
            @is_subscribed_to_newsletter
            );

        -- Insert into subtype
        INSERT INTO npss.visitors
        VALUES (@visitor_id)

        COMMIT TRANSACTION;
    END TRY

    -- Throw error upon failure, Undo changes (but only if a transaction actually occurred)
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

        RETURN 1
    END CATCH

    RETURN 0 -- Yay we did it
END;
GO

CREATE OR

ALTER PROCEDURE npss.SP_EnrollVisitorInProgram (
    @visitor_id VARCHAR(20),
    @park_name NVARCHAR(127),
    @program_name NVARCHAR(127),
    @visit_date DATE NOT NULL,
    @accessibility_needs NVARCHAR(127) NULL
    )
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRANSACTION

    -- Try to record enrollment
    BEGIN TRY
        INSERT INTO npss.program_enrollments
        VALUES (
            @visitor_id,
            @park_name,
            @program_name,
            @visit_date,
            @accessibility_needs
            );

        COMMIT TRANSACTION;
    END TRY

    -- Throw error upon failure, Undo changes (but only if a transaction actually occurred)
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

        RETURN 1
    END CATCH

    RETURN 0 -- Yay we did it
END;
GO

-- Query 2: Insert a new ranger into the database and assign them to a ranger team (2/month).
CREATE OR

ALTER PROCEDURE npss.SP_InsertRanger (
    @ranger_id VARCHAR(20),
    @first_name NVARCHAR(127),
    @middle_initial NCHAR,
    @last_name NVARCHAR(127),
    @date_of_birth DATE,
    @gender CHAR(1),
    @street NVARCHAR(127),
    @city NVARCHAR(127),
    @us_state CHAR(2),
    @zip VARCHAR(13),
    @is_subscribed_to_newsletter BIT
    )
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRANSACTION

    -- Try to insert ranger
    BEGIN TRY
        -- Insert into supertype
        INSERT INTO npss.individuals (
            id,
            first_name,
            middle_initial,
            last_name,
            date_of_birth,
            gender,
            street,
            city,
            us_state,
            zip,
            is_subscribed_to_newsletter
            )
        VALUES (
            @ranger_id,
            @first_name,
            @middle_initial,
            @last_name,
            @date_of_birth,
            @gender,
            @street,
            @city,
            @us_state,
            @zip,
            @is_subscribed_to_newsletter
            );

        -- Insert into subtype
        INSERT INTO npss.rangerd
        VALUES (@ranger_id)

        COMMIT TRANSACTION;
    END TRY

    -- Throw error upon failure, Undo changes (but only if a transaction actually occurred)
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

        RETURN 1
    END CATCH

    RETURN 0 -- Yay we did it
END;
GO

CREATE OR

ALTER PROCEDURE npss.SP_CertifyRanger (
    @ranger_id VARCHAR(20),
    @certification NVARCHAR(127)
    )
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRANSACTION

    -- Try to add certification
    BEGIN TRY
        INSERT INTO npss.ranger_certifications
        VALUES (
            @ranger_id,
            @certification
            );

        COMMIT TRANSACTION;
    END TRY

    -- Throw error upon failure, Undo changes (but only if a transaction actually occurred)
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

        RETURN 1
    END CATCH

    RETURN 0 -- Yay we did it
END;
GO

CREATE OR

ALTER PROCEDURE npss.SP_AssignRangerToTeam (
    @ranger_id VARCHAR(20),
    @team_id VARCHAR(20),
    @start_date DATE,
    @assignment_status NVARCHAR(10)
    )
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRANSACTION

    -- Try to add assignment
    BEGIN TRY
        INSERT INTO npss.ranger_assignments (
            ranger_id,
            team_id,
            start_date,
            assignment_status
            )
        VALUES (
            @ranger_id,
            @team_id,
            @start_date,
            @assignment_status
            )

        COMMIT TRANSACTION;
    END TRY

    -- Throw error upon failure, Undo changes (but only if a transaction actually occurred)
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

        RETURN 1
    END CATCH

    RETURN 0 -- Yay we did it
END;
GO

-- Query 3: Insert a new ranger team into the database and set its leader(1/month).
CREATE OR

ALTER PROCEDURE npss.SP_InsertRangerTeam (
    @team_id VARCHAR(20),
    @leader_id VARCHAR(20),
    @focus_area NVARCHAR(127),
    @formation_date DATE
    )
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRANSACTION

    -- Try to insert team
    BEGIN TRY
        INSERT INTO npss.ranger_teams
        VALUES (
            @team_id,
            @leader_id,
            @focus_area,
            @formation_date
            )

        -- Assign leader to team 
        INSERT INTO npss.ranger_assignments (
            ranger_id,
            team_id,
            start_date,
            assignment_status
            )
        VALUES (
            @leader_id,
            @team_id,
            @formation_date,
            'active'
            );

        COMMIT TRANSACTION;
    END TRY

    -- Throw error upon failure, Undo changes (but only if a transaction actually occurred)
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

        RETURN 1
    END CATCH

    RETURN 0 -- Yay we did it
END;
GO

-- Query 4: Insert a new donation from a donor (5/day).
CREATE OR

ALTER PROCEDURE npss.SP_InsertCardDonation (
    @park_name NVARCHAR(127),
    @donor_id VARCHAR(20),
    @donation_date DATE,
    @amount INT,
    @campaign_name NVARCHAR(127),
    @card_type NVARCHAR(127),
    @card_last_four_digits CHAR(4),
    @card_expiration_date DATE
    )
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRANSACTION

    -- Try to insert donation (donor must already exist in DB)
    BEGIN TRY
        INSERT INTO npss.donations
        VALUES (
            @park_name,
            @donor_id,
            @donation_date,
            @amount,
            @campaign_name,
            @card_type,
            @card_last_four_digits,
            @card_expiration_date
            )

        COMMIT TRANSACTION;
    END TRY

    -- Throw error upon failure, Undo changes (but only if a transaction actually occurred)
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

        RETURN 1
    END CATCH

    RETURN 0 -- Yay we did it
END;
GO

CREATE OR

ALTER PROCEDURE npss.SP_InsertCheckDonation (
    @park_name NVARCHAR(127),
    @donor_id VARCHAR(20),
    @donation_date DATE,
    @amount INT,
    @campaign_name NVARCHAR(127),
    @check_number INT
    )
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRANSACTION

    -- Try to insert donation (donor must already exist in DB)
    BEGIN TRY
        INSERT INTO npss.donations
        VALUES (
            @donor_id,
            @check_number,
            @park_name,
            @donation_date,
            @amount,
            @campaign_name
            )

        COMMIT TRANSACTION;
    END TRY

    -- Throw error upon failure, Undo changes (but only if a transaction actually occurred)
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

        RETURN 1
    END CATCH

    RETURN 0 -- Yay we did it
END;
GO

-- Query 5: Insert a new researcher into the database and associate them with one or more ranger teams (1/year).
CREATE OR

ALTER PROCEDURE npss.SP_InsertResearcher @researcher_id VARCHAR(20),
    @first_name NVARCHAR(127),
    @middle_initial NCHAR(1),
    @last_name NVARCHAR(127),
    @date_of_birth DATE,
    @gender CHAR(1),
    @street NVARCHAR(127),
    @city NVARCHAR(127),
    @us_state CHAR(2),
    @zip VARCHAR(13),
    @is_subscribed_to_newsletter BIT,
    @research_field NVARCHAR(127),
    @hire_date DATE,
    @salary INT
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRANSACTION

    -- Try to insert researcher
    BEGIN TRY
        -- Insert into supertype
        INSERT INTO npss.individuals (
            id,
            first_name,
            middle_initial,
            last_name,
            date_of_birth,
            gender,
            street,
            city,
            us_state,
            zip,
            is_subscribed_to_newsletter
            )
        VALUES (
            @researcher_id,
            @first_name,
            @middle_initial,
            @last_name,
            @date_of_birth,
            @gender,
            @street,
            @city,
            @us_state,
            @zip,
            @is_subscribed_to_newsletter
            );

        -- Insert into subtype
        INSERT INTO npss.researchers (
            id,
            research_field,
            hire_date,
            salary
            )
        VALUES (
            @researcher_id,
            @research_field,
            @hire_date,
            @salary
            );

        COMMIT TRANSACTION;
    END TRY

    -- Throw error upon failure, Undo changes (but only if a transaction actually occurred)
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

        RETURN 1
    END CATCH

    RETURN 0 -- Yay we did it
END;
GO

CREATE OR

ALTER PROCEDURE npss.SP_AssociateResearcherWithTeam (
    @researcher_id VARCHAR(20),
    @team_id VARCHAR(20)
    )
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRANSACTION

    -- Try to associate researcher with team
    BEGIN TRY
        -- Set researcher_id column of given team to equal given researcher_id
        UPDATE npss.ranger_teams
        SET researcher_id = @researcher_id
        WHERE team_id = @team_id;

        COMMIT TRANSACTION;
    END TRY

    -- Throw error upon failure, Undo changes
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

        RETURN 1
    END CATCH

    RETURN 0 -- Yay we did it
END;
GO

-- Query 6: Insert a report submitted by a ranger team to a researcher (10/month).
CREATE OR

ALTER PROCEDURE npss.SP_InsertReport (
    @team_id VARCHAR(20),
    @report_date DATE,
    @researcher_id VARCHAR(20),
    @summary_of_activities NVARCHAR(MAX)
    )
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRANSACTION

    -- Try to insert report
    BEGIN TRY
        INSERT INTO npss.ranger_team_reports
        VALUES (
            @team_id,
            @researcher_id,
            @report_date,
            @summary_of_activities
            );

        COMMIT TRANSACTION;
    END TRY

    -- Throw error upon failure, Undo changes (but only if a transaction actually occurred)
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

        RETURN 1
    END CATCH

    RETURN 0 -- Yay we did it
END;
GO

-- Query 7: Insert a new park program into the database for a specific park (2/month).
CREATE OR

ALTER PROCEDURE npss.SP_InsertProgram (
    @program_name NVARCHAR(127),
    @park_name NVARCHAR(127),
    @program_type NVARCHAR(127),
    @start_date DATE,
    @duration TIME
    )
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRANSACTION

    -- Try to insert program
    BEGIN TRY
        INSERT INTO npss.programs
        VALUES (
            @program_name,
            @park_name,
            @program_type,
            @start_date,
            @duration
            );

        COMMIT TRANSACTION;
    END TRY

    -- Throw error upon failure, Undo changes (but only if a transaction actually occurred)
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

        RETURN 1
    END CATCH

    RETURN 0 -- Yay we did it
END;
GO

-- Query 8: Retrieve the names and contact information of all emergency contacts for a specific person (2/week).
CREATE OR

ALTER PROCEDURE npss.SP_RetrieveEmergencyContacts @individual_id VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    -- Retrieve all contacts associated with given individual
    SELECT ec.contact_name,
        ec.relationship,
        ec.phone_number
    FROM npss.emergency_contact ec
    WHERE ec.individual_id = @individual_id;
END;
GO

-- Query 9: Retrieve the list of visitors enrolled in a specific park program, including their accessibility needs (2/week).
CREATE OR

ALTER PROCEDURE npss.SP_RetrieveProgramVisitors @park_name NVARCHAR(127),
    @program_name NVARCHAR(127)
AS
BEGIN
    SET NOCOUNT ON;

    -- Retrieve each enrolled visitor's ID and needs
    SELECT pe.visitor_id,
        pe.accessibility_needs
    FROM npss.program_enrollments pe
    WHERE pe.park_name = @park_name AND pe.program_name = @program_name -- Filter by enrollment
    ORDER BY pe.visitor_id;
END;
GO

-- Query 10: Retrieve all park programs for a specific park that started after a given date (1/month).
CREATE OR

ALTER PROCEDURE npss.SP_RetrieveProgramsAfterDate @park_name NVARCHAR(127),
    @start_after DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Retrieve programs starting after given date
    SELECT p.program_name,
        p.program_type,
        p.start_date,
        p.duration
    FROM npss.program p
    WHERE p.park_name = @park_name AND p.start_date > @start_after -- Filter after given date
    ORDER BY p.start_date ASC;
END;
GO

-- Query 11: Retrieve the total and average donation amount received in a month from all anonymous donors. The result must be sorted by total amount of the donation in descending order (1/month).
CREATE OR

ALTER PROCEDURE npss.SP_RetrieveAnonymousDonations (
    @donation_year INT,
    @donation_month INT
    )
AS
BEGIN
    SET NOCOUNT ON;

    -- Filter for anonymous donors, combine card/check tables
    WITH anonymous_donations
    AS (
        -- Card donos
        SELECT cards.donor_id,
            cards.amount,
            cards.donation_date
        FROM npss.card_donations cards
        INNER JOIN npss.donors d
            ON cards.donor_id = d.donor_id
        WHERE d.prefers_anonymity = 1
        
        UNION ALL
        
        -- Check donos
        SELECT checks.donor_id,
            checks.amount,
            checks.donation_date
        FROM npss.check_donations checks
        INNER JOIN npss.donors d
            ON checks.donor_id = d.donor_id
        WHERE d.prefers_anonymity = 1
        )
    -- Group by donor id, calculate metrics
    SELECT donor_id,
        SUM(amount) AS total,
        AVG(CAST(amount AS DECIMAL(10, 2))) AS average
    FROM anonymous_donations
    WHERE YEAR(donation_date) = @donation_year AND MONTH(donation_date) = @donation_month
    GROUP BY donor_id
    ORDER BY total DESC
END;
GO

-- Query 12: Retrieve the list of rangers in a team, including their certifications, years of service and their role in the team (leader or member) (4/year).
CREATE OR

ALTER PROCEDURE npss.SP_RetrieveTeam @team_id VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ind.id AS ranger_id,
        ind.first_name,
        ind.last_name,
        ra.start_date,
        ra.years_of_service,
        CASE -- Determine role
            WHEN ra.ranger_id = rt.leader_id
                THEN 'leader'
            ELSE 'member'
            END AS team_role,
        STRING_AGG(rc.certification, ', ') AS certifications --  -- Aggregate all certs into a single string
    FROM npss.individuals ind
    INNER JOIN npss.rangers r -- Join to get name
        ON ind.id = r.ranger_id
    INNER JOIN npss.ranger_assignments ra -- Join to get assignment details
        ON r.ranger_id = ra.ranger_id
    INNER JOIN npss.ranger_teams rt -- Join to get leader id
        ON ra.team_id = rt.team_id
    LEFT JOIN npss.ranger_certifications rc -- Left join to include rangers with no certs
        ON r.ranger_id = rc.ranger_id
    WHERE ra.team_id = @team_id
    GROUP BY ind.id,
        ind.first_name,
        ind.last_name,
        ra.start_date,
        ra.ranger_id,
        rt.leader_id
    ORDER BY team_role DESC, -- Leader first, then members alphabetically
        ind.last_name ASC;
END;
GO

-- Query 13: Retrieve the names, IDs, contact information, and newsletter subscription status of all individuals in the database (1/week).
CREATE OR

ALTER PROCEDURE npss.SP_RetrieveAllIndividuals
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ind.id,
        ind.first_name,
        ind.middle_initial,
        ind.last_name,
        ind.is_subscribed_to_newsletter,
        STRING_AGG(phones.phone_number, ', ') AS phone_numbers, -- Aggregate all phone numbers into a single string
        STRING_AGG(emails.email_address, ', ') AS email_addresses -- Aggregate all email addresses into a single string
    FROM npss.individuals ind
    LEFT JOIN npss.individual_phone_number phones -- Join to get phones
        ON ind.id = phones.individual_id
    LEFT JOIN npss.individual_email_address emails -- Joine to get emails
        ON ind.id = emails.individual_id
    -- Reduce to one row per individual
    GROUP BY ind.id,
        ind.first_name,
        ind.middle_initial,
        ind.last_name,
        ind.is_subscribed_to_newsletter
    ORDER BY ind.last_name,
        ind.first_name;
END;
GO

-- 14. Update the salary of researchers overseeing more than one ranger team by a 3% increase (1/year).
CREATE OR

ALTER PROCEDURE npss.SP_UpdateResearcherSalaries
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    -- Try to update salaries
    BEGIN TRY
        -- Filter to just the researchers w/ multiple teams
        WITH researchers_multiple_teams
        AS (
            SELECT tr.researcher_id
            FROM npss.team_report tr
            GROUP BY tr.researcher_id
            HAVING COUNT(DISTINCT tr.team_id) > 1 -- Count distinct teams
            )
        UPDATE r
        SET salary = r.salary * 1.03 -- +3%
        FROM npss.researchers r
        INNER JOIN researchers_multiple_teams rmt -- Join to select just the above researchers
            ON r.id = rmt.researcher_id;

        COMMIT TRANSACTION;
    END TRY

    -- Throw error upon failure, Undo changes (but only if a transaction actually occurred)
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

        RETURN 1
    END CATCH

    RETURN 0 -- Yay we did it
END;
GO

-- 15. Delete visitors who have not enrolled in any park programs and whose park passes have expired (2/year).
CREATE OR

ALTER PROCEDURE npss.SP_DeleteInactiveVisitors
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    -- Try to delete visitors
    BEGIN TRY
        -- Filter to inactive visitors
        WITH inactive
        AS (
            SELECT v.id
            FROM npss.visitors v
            WHERE
                -- Not enrolled in any programs
                NOT EXISTS (
                    SELECT 1
                    FROM npss.program_enrollments pe
                    WHERE pe.visitor_id = v.id
                    )
                -- Holds no non-expired passes
                AND NOT EXISTS (
                    SELECT 1
                    FROM npss.park_passes pp
                    WHERE pp.visitor_id = v.id AND pp.expiration_date > GETDATE()
                    )
            )
        -- Delete their passes
        DELETE
        FROM pp
        FROM npss.park_passes pp
        INNER JOIN inactive iv
            ON pp.visitor_id = iv.id;

        -- Delete the visitor
        DELETE
        FROM v
        FROM npss.visitors v
        INNER JOIN inactive iv
            ON v.id = iv.id;

        -- Delete the individual
        DELETE
        FROM i
        FROM npss.individuals i
        INNER JOIN inactive iv
            ON i.id = iv.id
        -- UNLESS they're some other role too
        WHERE
            NOT EXISTS (
                SELECT 1
                FROM npss.donors d
                WHERE d.id = i.id
                )
            AND NOT EXISTS (
                SELECT 1
                FROM npss.rangers r
                WHERE r.id = i.id
                )
            AND NOT EXISTS (
                SELECT 1
                FROM npss.researchers res
                WHERE res.id = i.id
                );

        COMMIT TRANSACTION;
    END TRY

    -- Throw error upon failure, Undo changes (but only if a transaction actually occurred)
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

        RETURN 1
    END CATCH

    RETURN 0 -- Yay we did it
END;
GO


