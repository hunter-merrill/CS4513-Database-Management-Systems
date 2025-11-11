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
    @team_id VARCHAR(20),
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

CREATE OR

ALTER PROCEDURE npss.SP_InsertReport(
    @team_id VARCHAR(20),
    @report_date DATE,
    @researcher_id VARCHAR(20),
    @summary_of_activities NVARCHAR(MAX),
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

CREATE OR

ALTER PROCEDURE npss.
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRANSACTION

    -- 
    BEGIN TRY
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


