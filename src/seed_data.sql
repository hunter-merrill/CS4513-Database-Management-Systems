-- Supertype
INSERT INTO npss.individuals
VALUES ('V1887A', 'Leslie', 'C', 'Knope', '1975-01-18', 'F', '101 Pawnee St', 'Pawnee', 'IN', '47999', 1);

INSERT INTO npss.individuals
VALUES ('R2093M', 'Ron', 'F', 'Swanson', '1967-05-06', 'M', '789 Cabin Rd', 'Bozeman', 'MT', '59715', 0);

INSERT INTO npss.individuals
VALUES ('RS444B', 'Bill', 'S', 'Nye', '1955-11-27', 'M', '42 Science Way', 'Seattle', 'WA', '98109', 1);

INSERT INTO npss.individuals
VALUES ('D5555Z', 'Mario', NULL, 'Mario', '1981-07-09', 'M', '1-1 Mushroom Ln', 'Mushroom Kingdom', 'CA', '90210', 1);

INSERT INTO npss.individuals
VALUES ('D6666Z', 'Luigi', NULL, 'Mario', '1981-07-09', 'M', '1-1 Mushroom Ln', 'Mushroom Kingdom', 'CA', '90210', 1);

INSERT INTO npss.individuals
VALUES ('D7777Z', 'Wario', NULL, 'Wario', '1981-07-09', 'M', '1-1 Mushroom Ln', 'Mushroom Kingdom', 'CA', '90210', 1);

INSERT INTO npss.individuals
VALUES ('D8888Z', 'Waluigi', NULL, 'Wario', '1981-07-09', 'M', '1-1 Mushroom Ln', 'Mushroom Kingdom', 'CA', '90210', 1);



-- Subtypes
INSERT INTO npss.rangers
VALUES ('R2093M');
INSERT INTO npss.rangers
VALUES ('D6666Z');
INSERT INTO npss.rangers
VALUES ('D7777Z');
INSERT INTO npss.rangers
VALUES ('D8888Z');

INSERT INTO npss.researchers (researcher_id, research_field, hire_date, salary)
VALUES ('RS444B', 'Science', '2010-09-01', 456000);

INSERT INTO npss.visitors
VALUES ('V1887A');

INSERT INTO npss.donors (donor_id, prefers_anonymity)
VALUES ('D5555Z', 1);



-- Park
INSERT INTO npss.parks (park_name, street, city, us_state, zip, establishment_date, visitor_capacity)
VALUES ('Yellowstone', 'West Entrance Rd', 'West Yellowstone', 'MT', '59758', '1872-03-01', 4000000);



-- Ranger teams
INSERT INTO npss.ranger_teams (team_id, leader_id, focus_area, formation_date, researcher_id)
VALUES ('TEAM-1', 'R2093M', 'Trail Restoration', '2018-05-01', 'RS444B');

INSERT INTO npss.ranger_teams (team_id, leader_id, focus_area, formation_date, researcher_id)
VALUES ('TEAM-6', 'R2093M', 'Trail Restoration', '2018-05-01', 'RS444B');



-- Relationships
INSERT INTO npss.programs (program_name, park_name, program_type, start_date, duration)
VALUES ('Geyser Walk', 'Yellowstone', 'Recreational', '2025-06-15', '01:30:00');

INSERT INTO npss.ranger_assignments (ranger_id, team_id, start_date, assignment_status)
VALUES ('R2093M', 'TEAM-1', '2018-05-01', 'active');
