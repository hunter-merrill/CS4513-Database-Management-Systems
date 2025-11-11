----- TASK IV: Table Creation -----
-- CREATE SCHEMA npss; -- I ran this once to create the National Parks Service System schema
-- Individuals
CREATE TABLE npss.individuals (
    id VARCHAR(20) PRIMARY KEY,
    first_name NVARCHAR(127) NOT NULL,
    middle_initial NCHAR,
    last_name NVARCHAR(127) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender CHAR(1) NOT NULL,
    street NVARCHAR(127) NOT NULL,
    city NVARCHAR(127) NOT NULL,
    us_state CHAR(2) NOT NULL,
    zip VARCHAR(13) NOT NULL,
    age AS DATEDIFF(year, date_of_birth, CAST(GETDATE() AS DATE)),
    is_subscribed_to_newsletter BIT NOT NULL
    );
GO

CREATE TABLE npss.individual_phone_numbers (
    individual_id VARCHAR(20),
    phone_number VARCHAR(20),
    PRIMARY KEY (
        individual_id,
        phone_number
        ),
    CONSTRAINT FK_PhoneNumbers_Individuals FOREIGN KEY (individual_id) REFERENCES npss.individuals(id)
    );
GO

CREATE TABLE npss.individual_email_addresses (
    individual_id VARCHAR(20),
    email_address VARCHAR(127),
    PRIMARY KEY (
        individual_id,
        email_address
        ),
    CONSTRAINT FK_EmailAddresses_Individuals FOREIGN KEY (individual_id) REFERENCES npss.individuals(id)
    );
GO

CREATE TABLE npss.emergency_contacts (
    individual_id VARCHAR(20),
    phone_number VARCHAR(20),
    first_name NVARCHAR(127) NOT NULL,
    middle_initial NCHAR NOT NULL,
    last_name NVARCHAR(127) NOT NULL,
    relationship NVARCHAR(127) NOT NULL,
    PRIMARY KEY (
        individual_id,
        phone_number
        ),
    CONSTRAINT FK_EmergencyContacts_Individuals FOREIGN KEY (individual_id) REFERENCES npss.individuals(id)
    );
GO

-- Rangers
CREATE TABLE npss.rangers (
    ranger_id VARCHAR(20) PRIMARY KEY,
    CONSTRAINT FK_Rangers_Individuals FOREIGN KEY (ranger_id) REFERENCES npss.individuals(id)
    );
GO

CREATE TABLE npss.ranger_certifications (
    ranger_id VARCHAR(20),
    certification NVARCHAR(127),
    PRIMARY KEY (
        ranger_id,
        certification
        ),
    CONSTRAINT FK_Certifications_Rangers FOREIGN KEY (ranger_id) REFERENCES npss.rangers(ranger_id)
    );
GO

CREATE TABLE npss.researchers (
    researcher_id VARCHAR(20) PRIMARY KEY,
    research_field NVARCHAR(127) NOT NULL,
    hire_date DATE NOT NULL,
    salary INT NOT NULL,
    CONSTRAINT FK_Researchers_Individuals FOREIGN KEY (researcher_id) REFERENCES npss.individuals(id)
    );
GO

CREATE TABLE npss.ranger_teams (
    team_id VARCHAR(20) PRIMARY KEY,
    leader_id VARCHAR(20) NOT NULL,
    focus_area NVARCHAR(127) NOT NULL,
    formation_date DATE NOT NULL,
    researcher_id VARCHAR(20) NULL,
    CONSTRAINT FK_Teams_Rangers FOREIGN KEY (leader_id) REFERENCES npss.rangers(ranger_id),
    CONSTRAINT FK_Teams_Researchers FOREIGN KEY (researcher_id) REFERENCES npss.researchers(researcher_id)
    );
GO

-- National Parks
CREATE TABLE npss.parks (
    park_name NVARCHAR(127) PRIMARY KEY,
    street NVARCHAR(127) NOT NULL,
    city NVARCHAR(127) NOT NULL,
    us_state CHAR(2) NOT NULL,
    zip VARCHAR(13) NOT NULL,
    establishment_date DATE NOT NULL,
    visitor_capacity INT NOT NULL
    );
GO

CREATE TABLE npss.projects (
    project_id VARCHAR(20) PRIMARY KEY,
    park_name NVARCHAR(127) NOT NULL,
    project_name NVARCHAR(127) NOT NULL,
    start_date DATE NOT NULL,
    budget INT NOT NULL,
    CONSTRAINT FK_Projects_NationalParks FOREIGN KEY (park_name) REFERENCES npss.parks(park_name)
    );
GO

CREATE TABLE npss.programs (
    program_name NVARCHAR(127),
    park_name NVARCHAR(127),
    program_type NVARCHAR(127) NOT NULL,
    start_date DATE NOT NULL,
    duration TIME NOT NULL,
    PRIMARY KEY (
        program_name,
        park_name
        ),
    CONSTRAINT FK_Programs_NationalParks FOREIGN KEY (park_name) REFERENCES npss.parks(park_name)
    );
GO

-- Visitors
CREATE TABLE npss.visitors (
    visitor_id VARCHAR(20) PRIMARY KEY,
    CONSTRAINT FK_Visitors_Individuals FOREIGN KEY (visitor_id) REFERENCES npss.individuals(id)
    );
GO

CREATE TABLE npss.park_passes (
    pass_id VARCHAR(20) PRIMARY KEY,
    visitor_id VARCHAR(20) NOT NULL,
    pass_type NVARCHAR(127) NOT NULL,
    expiration_date DATE NOT NULL,
    CONSTRAINT FK_Passes_Visitors FOREIGN KEY (visitor_id) REFERENCES npss.visitors(visitor_id)
    );
GO

-- Donations
CREATE TABLE npss.donors (
    donor_id VARCHAR(20) PRIMARY KEY,
    prefers_anonymity BIT NOT NULL,
    CONSTRAINT FK_Donors_Individuals FOREIGN KEY (donor_id) REFERENCES npss.individuals(id)
    );
GO

CREATE TABLE npss.card_donations (
    park_name NVARCHAR(127),
    donor_id VARCHAR(20),
    donation_date DATE,
    amount INT NOT NULL,
    campaign_name NVARCHAR(127),
    card_type NVARCHAR(127) NOT NULL,
    card_last_four_digits CHAR(4) NOT NULL,
    card_expiration_date DATE NOT NULL,
    PRIMARY KEY (
        park_name,
        donor_id,
        donation_date
        ),
    CONSTRAINT FK_CardDonations_Parks FOREIGN KEY (park_name) REFERENCES npss.parks(park_name),
    CONSTRAINT FK_CardDonations_Donors FOREIGN KEY (donor_id) REFERENCES npss.donors(donor_id)
    );
GO

CREATE TABLE npss.check_donations (
    donor_id VARCHAR(20),
    check_number INT,
    park_name NVARCHAR(127) NOT NULL,
    donation_date DATE NOT NULL,
    amount INT NOT NULL,
    campaign_name NVARCHAR(127) NULL,
    PRIMARY KEY (
        donor_id,
        check_number
        ),
    CONSTRAINT FK_CheckdDonations_Parks FOREIGN KEY (park_name) REFERENCES npss.parks(park_name),
    CONSTRAINT FK_CheckDonations_Donors FOREIGN KEY (donor_id) REFERENCES npss.donors(donor_id)
    );
GO

-- Relationships
CREATE TABLE npss.ranger_mentorships (
    mentee_id VARCHAR(20) PRIMARY KEY,
    mentor_id VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    CONSTRAINT FK_Mentorship_Mentee FOREIGN KEY (mentee_id) REFERENCES npss.rangers(ranger_id),
    CONSTRAINT FK_Mentorship_Mentor FOREIGN KEY (mentor_id) REFERENCES npss.rangers(ranger_id)
    );
GO

CREATE TABLE npss.ranger_assignments (
    ranger_id VARCHAR(20) PRIMARY KEY,
    team_id VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    years_of_service AS DATEDIFF(year, start_date, CAST(GETDATE() AS DATE)),
    assignment_status NVARCHAR(10) NOT NULL CHECK (assignment_status IN ('active', 'inactive')),
    CONSTRAINT FK_Assignments_Rangers FOREIGN KEY (ranger_id) REFERENCES npss.rangers(ranger_id),
    CONSTRAINT FK_Assignments_Teams FOREIGN KEY (team_id) REFERENCES npss.ranger_teams(team_id)
    );
GO

CREATE TABLE npss.ranger_team_reports (
    team_id VARCHAR(20),
    report_date DATE,
    researcher_id VARCHAR(20) NOT NULL,
    summary_of_activities NVARCHAR(MAX) NOT NULL,
    PRIMARY KEY (
        team_id,
        report_date
        ),
    CONSTRAINT FK_ReportsTo_Team FOREIGN KEY (team_id) REFERENCES npss.ranger_teams(team_id),
    CONSTRAINT FK_ReportsTo_Researcher FOREIGN KEY (researcher_id) REFERENCES npss.researchers(researcher_id)
    );
GO

CREATE TABLE npss.program_enrollments (
    visitor_id VARCHAR(20),
    park_name NVARCHAR(127),
    program_name NVARCHAR(127),
    visit_date DATE NOT NULL,
    accessibility_needs NVARCHAR(127) NULL,
    PRIMARY KEY (
        visitor_id,
        program_name,
        park_name
        ),
    CONSTRAINT FK_Enrollments_Visitors FOREIGN KEY (visitor_id) REFERENCES npss.visitors(visitor_id),
    CONSTRAINT FK_Enrollments_Programs FOREIGN KEY (
        program_name,
        park_name
        ) REFERENCES npss.programs(program_name, park_name)
    );
GO


