CREATE DATABASE HR_Analytics
USE HR_Analytics
---------------------------------------------------------
---------------------------------------------------------
-- 1. Create a schema to isolate our dirty raw data
CREATE SCHEMA stg;
GO

-- 2. Create the PerformanceRating Table
CREATE TABLE stg.raw_PerformanceRating (
    Performance_ID NVARCHAR(255),
    Employee_ID NVARCHAR(255),
    Review_Date NVARCHAR(255),
    Environment_Satisfaction NVARCHAR(255),
    Job_Satisfaction NVARCHAR(255),
    Relationship_Satisfaction NVARCHAR(255),
    Training_Opportunities_Within_Year NVARCHAR(255),
    Training_Opportunities_Taken NVARCHAR(255),
    WorkLife_Balance NVARCHAR(255),
    Self_Rating NVARCHAR(255),
    Manager_Rating NVARCHAR(255)
);
GO

-- 3. Create the Employee Table
CREATE TABLE stg.raw_Employee (
    Employee_ID NVARCHAR(255),
    First_Name NVARCHAR(255),
    Last_Name NVARCHAR(255),
    Gender NVARCHAR(255),
    Age NVARCHAR(255),
    Business_Travel NVARCHAR(255),
    Department NVARCHAR(255),
    Distance_From_Home NVARCHAR(255),
    State NVARCHAR(255),
    Ethnicity NVARCHAR(255),
    Education NVARCHAR(255),
    Education_Field NVARCHAR(255),
    Job_Role NVARCHAR(255),
    Marital_Status NVARCHAR(255),
    Salary NVARCHAR(255),
    Stock_Option_Level NVARCHAR(255),
    Over_Time NVARCHAR(255),
    Hire_Date NVARCHAR(255),
    Attrition NVARCHAR(255),
    Years_At_Company NVARCHAR(255),
    Years_In_Most_Recent_Role NVARCHAR(255),
    YearsSince_Last_Promotion NVARCHAR(255),
    Years_With_Curr_Manager NVARCHAR(255)
);
GO

-- 4. Create the SatisfiedLevel Table
CREATE TABLE stg.raw_SatisfiedLevel (
    Satisfaction_ID NVARCHAR(255),
    Satisfaction_Level NVARCHAR(255)
);
GO

-- 5. Create the RatingLevel Table
CREATE TABLE stg.raw_RatingLevel (
    Rating_ID NVARCHAR(255),
    Rating_Level NVARCHAR(255)
);
GO

-- 6. Create the EducationLevel Table
CREATE TABLE stg.raw_EducationLevel (
    EducationLevel_ID NVARCHAR(255),
    Education_Level NVARCHAR(255)
);
GO

---------------------------------------------------------
-- Pour the HR data into our staging table
INSERT INTO stg.raw_PerformanceRating
SELECT * 
FROM dbo.PerformanceRating; 
SELECT * FROM stg.raw_PerformanceRating

INSERT INTO stg.raw_Employee
SELECT * 
FROM dbo.Employee; 
SELECT * FROM stg.raw_Employee

INSERT INTO stg.raw_SatisfiedLevel
SELECT * 
FROM dbo.SatisfiedLevel; 
SELECT * FROM stg.raw_SatisfiedLevel

INSERT INTO stg.raw_RatingLevel
SELECT * 
FROM dbo.RatingLevel; 
SELECT * FROM stg.raw_RatingLevel

INSERT INTO stg.raw_EducationLevel
SELECT * 
FROM dbo.EducationLevel; 
SELECT * FROM stg.raw_EducationLevel
-------------------------------------------------------------
-------------------------------------------------------------
DROP TABLE dbo.PerformanceRating
DROP TABLE dbo.Employee
DROP TABLE dbo.SatisfiedLevel
DROP TABLE dbo.RatingLevel
DROP TABLE dbo.EducationLevel

-----------------------------


