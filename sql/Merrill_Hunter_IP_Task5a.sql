-- Query 1: Insert a new visitor into the database and associate them with one or more park programs (10/day).
CREATE OR ALTER PROCEDURE npss.SP_InsertVisitor
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
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRANSACTION

    -- Try to insert visitor
    BEGIN TRY
        INSERT INTO npss.individuals
    VALUES
        (@visitor_id, @first_name, @middle_intial, @last_name, @date_of_birth,
            @gender, @street, @city, @us_state, @zip, @is_subscribed_to_newsletter);
        INSERT INTO npss.visitors
    VALUES
        (@visitor_id)
    END TRY

    -- Throw error upon failure, Undo changes (but only if a transaction actually occurred)
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
        RETURN 1
    END CATCH

    -- Yay we did it
    RETURN 0
END;
GO

CREATE OR ALTER PROCEDURE npss.SP_EnrollVisitorInProgram
    @visitor_id VARCHAR(20),
    @park_name NVARCHAR(127),
    @program_name NVARCHAR(127),
    @visit_date DATE NOT NULL,
    @accessibility_needs NVARCHAR(127) NULL
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRANSACTION

    -- Try to record enrollment
    BEGIN TRY
    INSERT INTO npss.program_enrollments
    VALUES
        (@visitor_id, @park_name, @program_name, @visit_date, @accessibility_needs);
    END TRY

    -- Throw error upon failure, Undo changes (but only if a transaction actually occurred)
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
        RETURN 1
    END CATCH

    -- Yay we did it
    RETURN 0
END;
GO



CREATE OR ALTER PROCEDURE npss.
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRANSACTION

    -- Try to record enrollment
    BEGIN TRY
    END TRY

    -- Throw error upon failure, Undo changes (but only if a transaction actually occurred)
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
        RETURN 1
    END CATCH

    -- Yay we did it
    RETURN 0
END;
GO