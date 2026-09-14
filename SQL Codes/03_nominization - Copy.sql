USE HR_Analytics
-- =======================================================================
-- HR Analytics Employee Attrition & Performance - PHASE 3: ODS CREATION & LOADING (CORRECTED)
-- Environment: SQL Server (T-SQL)
-- =======================================================================

-- 0. Clean up previous failed attempts

DROP TABLE IF EXISTS ods.PerformanceRating;
DROP TABLE IF EXISTS ods.Employee;
DROP TABLE IF EXISTS ods.Ratinglevel;
DROP TABLE IF EXISTS ods.Satisfiedlevel; 
DROP TABLE IF EXISTS ods.Education_level;
DROP TABLE IF EXISTS ods.Departments;
DROP TABLE IF EXISTS ods.Education_Field;
DROP TABLE IF EXISTS ods.Job_Role;
GO

-- 1. Create the schema (if not exists)
CREATE SCHEMA ods;
GO

-- =======================================================================
-- PART A: CREATE TABLES (DDL)
-- =======================================================================
CREATE TABLE ods.Departments (
    Department_ID INT IDENTITY(1,1) PRIMARY KEY,
    Department_Name NVARCHAR(50) NOT NULL
);

CREATE TABLE ods.Education_level (
    EducationLevel_ID INT IDENTITY(1,1) PRIMARY KEY,
    Education_level NVARCHAR(50) NOT NULL
);

CREATE TABLE ods.Education_Field (
    Education_Field_ID INT IDENTITY(1,1) PRIMARY KEY,
    Education_Field NVARCHAR(50) NOT NULL
);

CREATE TABLE ods.Job_Role (
    Job_Role_ID INT IDENTITY(1,1) PRIMARY KEY,
    Job_Role NVARCHAR(50) NOT NULL
);

CREATE TABLE ods.Employee (
    Employee_ID INT IDENTITY(1,1) PRIMARY KEY,
    Employee_Code NVARCHAR(50),
    First_Name NVARCHAR(50),
    Last_Name NVARCHAR(50),
    Gender NVARCHAR(50),
    Age INT,
    Business_Travel NVARCHAR(50),
    Distance_From_Home INT,
    State NVARCHAR(10),
    Ethnicity NVARCHAR(50),
    Marital_Status NVARCHAR(20),
    Salary Decimal(10,2),
    Stock_Option_Level INT,
    Over_Time NVARCHAR(10),
    Hire_Date Date Default GetDate(),
    Attrition NVARCHAR(10),
    Years_At_Company INT,
    Years_In_Most_Recent_Role INT,
    YearsSince_Last_Promotion INT,
    Years_With_Curr_Manager INT,
    Department_ID INT FOREIGN KEY REFERENCES ods.Departments (Department_ID),
    Education_level_ID INT FOREIGN KEY REFERENCES ods.Education_level (EducationLevel_ID ),
    Education_Field_ID INT FOREIGN KEY REFERENCES ods.Education_Field (Education_Field_ID),
    Job_Role_ID INT FOREIGN KEY REFERENCES ods.Job_Role (Job_Role_ID)
);

----------

CREATE TABLE ods.Satisfiedlevel (
    Satisfaction_Level_ID INT IDENTITY(1,1) PRIMARY KEY,
    Satisfaction_Level NVARCHAR(50)
);

CREATE TABLE ods.Ratinglevel (
    Rating_Level_ID INT IDENTITY(1,1) PRIMARY KEY,
    Rating_Level NVARCHAR(50)
);

CREATE TABLE ods.PerformanceRating (
    Performance_ID int IDENTITY(1,1) PRIMARY KEY,
    Performance_Code NVARCHAR(50),
    Employee_ID INT FOREIGN KEY REFERENCES ods.Employee (Employee_ID),
    Review_Date Date Default GetDate(),
    Environment_Satisfaction INT FOREIGN KEY REFERENCES ods.Satisfiedlevel (Satisfaction_Level_ID),
    Job_Satisfaction INT FOREIGN KEY REFERENCES ods.Satisfiedlevel (Satisfaction_Level_ID),
    Relationship_Satisfaction INT FOREIGN KEY REFERENCES ods.Satisfiedlevel (Satisfaction_Level_ID),
    WorkLife_Balance INT FOREIGN KEY REFERENCES ods.Satisfiedlevel (Satisfaction_Level_ID),
    Self_Rating INT FOREIGN KEY REFERENCES ods.Ratinglevel (Rating_level_ID),
    Manager_Rating INT FOREIGN KEY REFERENCES ods.Ratinglevel (Rating_level_ID),
    Training_Opportunities_Within_Year INT,
    Training_Opportunities_Taken INT, 
    CONSTRAINT UQ_PerformanceReview_Employee_ReviewDate UNIQUE (Employee_ID, Review_Date)
);

-- 1. Load Independent Dimension Tables
INSERT INTO ods.Departments (Department_Name)
SELECT DISTINCT Department FROM stg.vw_clean_Employee WHERE Department IS NOT NULL;
SELECT * FROM ods.Departments

INSERT INTO ods.Education_Field (Education_Field)
SELECT DISTINCT Education_Field FROM stg.vw_clean_Employee WHERE Education_Field IS NOT NULL;
SELECT * FROM ods.Education_Field

SET IDENTITY_INSERT ods.Education_level ON;
INSERT INTO ods.Education_level (EducationLevel_ID, Education_level)
SELECT DISTINCT EducationLevel_ID, Education_Level 
FROM stg.vw_clean_EducationLevel WHERE Education_Level IS NOT NULL;
SET IDENTITY_INSERT ods.Education_level OFF;
SELECT * FROM ods.Education_level

INSERT INTO ods.Job_Role (Job_Role)
SELECT DISTINCT Job_Role FROM stg.vw_clean_Employee WHERE Job_Role IS NOT NULL;
SELECT * FROM ods.Job_Role


-- 2. Load Dependent Dimension Tables

INSERT INTO ods.Employee (
    Employee_Code, 
    First_Name, 
    Last_Name, 
    Gender, 
    Age, 
    Business_Travel, 
    Distance_From_Home, 
    State, 
    Ethnicity, 
    Marital_Status, 
    Salary, 
    Stock_Option_Level, 
    Over_Time, 
    Hire_Date, 
    Attrition, 
    Years_At_Company,
    Years_In_Most_Recent_Role, 
    YearsSince_Last_Promotion, 
    Years_With_Curr_Manager, 
    Department_ID,
    Education_level_ID, 
    Education_Field_ID, 
    Job_Role_ID 
    )
SELECT 
    emp.Employee_ID, 
    emp.First_Name, 
    emp.Last_Name, 
    emp.Gender, 
    emp.Age, 
    emp.Business_Travel,
    emp.Distance_From_Home, 
    emp.State, 
    emp.Ethnicity, 
    emp.Marital_Status, 
    emp.Salary, 
    emp.Stock_Option_Level, 
    emp.Over_Time, 
    emp.Hire_Date, 
    emp.Attrition, 
    emp.Years_At_Company, 
    emp.Years_In_Most_Recent_Role, 
    emp.YearsSince_Last_Promotion, 
    emp.Years_With_Curr_Manager, 
    d.Department_ID , 
    edl.EducationLevel_ID, 
    edf.Education_Field_ID, 
    jr.Job_Role_ID 
FROM stg.vw_clean_Employee AS emp
LEFT JOIN ods.Departments d ON emp.Department = d.Department_Name
lEFT JOIN ods.Education_level edl  ON emp.Education = edl.EducationLevel_ID
LEFT JOIN ods.Education_Field edf ON emp.Education_Field = edf.Education_Field
LEFT JOIN ods.Job_Role jr ON emp.Job_Role = jr.Job_Role;
SELECT * FROM ods.Employee
-----------------------------------------------------------------------------------------------------------------------
SET IDENTITY_INSERT ods.Satisfiedlevel ON;
INSERT INTO ods.Satisfiedlevel (Satisfaction_Level_ID, Satisfaction_Level)
SELECT DISTINCT Satisfaction_ID, Satisfaction_Level 
FROM stg.vw_clean_SatisfiedLevel 
WHERE Satisfaction_Level IS NOT NULL;
SET IDENTITY_INSERT ods.Satisfiedlevel OFF;
SELECT * FROM ods.Satisfiedlevel
-----------------------------------------------------------------------------------------------------------------------
SET IDENTITY_INSERT ods.Ratinglevel ON;
INSERT INTO ods.Ratinglevel (Rating_Level_ID, Rating_Level)
SELECT DISTINCT Rating_ID, Rating_Level 
FROM stg.vw_clean_RatingLevel 
WHERE Rating_Level IS NOT NULL;
SET IDENTITY_INSERT ods.Ratinglevel OFF;
SELECT * FROM ods.Ratinglevel

-----------------------------------------------------------------------------------------------------------------------
INSERT INTO ods.PerformanceRating
(
    Performance_Code,
    Employee_ID,
    Review_Date,
    Environment_Satisfaction,
    Job_Satisfaction,
    Relationship_Satisfaction,
    WorkLife_Balance,
    Self_Rating,
    Manager_Rating,
    Training_Opportunities_Within_Year,
    Training_Opportunities_Taken
)
SELECT
    pr.Performance_ID                     AS Performance_Code,
    e.Employee_ID                         AS Employee_ID,
    pr.Review_Date,
    env_sat.Satisfaction_Level_ID         AS Environment_Satisfaction,
    job_sat.Satisfaction_Level_ID         AS Job_Satisfaction,
    rel_sat.Satisfaction_Level_ID         AS Relationship_Satisfaction,
    work_sat.Satisfaction_Level_ID        AS WorkLife_Balance,
    self_rate.Rating_Level_ID             AS Self_Rating,
    manager_rate.Rating_Level_ID          AS Manager_Rating,
    pr.Training_Opportunities_Within_Year,
    pr.Training_Opportunities_Taken
FROM stg.vw_clean_PerformanceRating AS pr

INNER JOIN ods.Employee AS e
    ON e.Employee_Code = pr.Employee_ID

INNER JOIN ods.Satisfiedlevel AS env_sat
    ON env_sat.Satisfaction_Level_ID =
       pr.Environment_Satisfaction

INNER JOIN ods.Satisfiedlevel AS job_sat
    ON job_sat.Satisfaction_Level_ID =
       pr.Job_Satisfaction

INNER JOIN ods.Satisfiedlevel AS rel_sat
    ON rel_sat.Satisfaction_Level_ID =
       pr.Relationship_Satisfaction

INNER JOIN ods.Satisfiedlevel AS work_sat
    ON work_sat.Satisfaction_Level_ID =
       pr.WorkLife_Balance

INNER JOIN ods.Ratinglevel AS self_rate
    ON self_rate.Rating_Level_ID = pr.Self_Rating

INNER JOIN ods.Ratinglevel AS manager_rate
    ON manager_rate.Rating_Level_ID = pr.Manager_Rating

WHERE
    pr.Performance_ID IS NOT NULL
    AND pr.Review_Date IS NOT NULL

    AND NOT EXISTS
    (
        SELECT 1
        FROM ods.PerformanceRating AS existing
        WHERE existing.Employee_ID = e.Employee_ID
          AND existing.Review_Date = pr.Review_Date
    );
GO
------------------------------------------------------------
