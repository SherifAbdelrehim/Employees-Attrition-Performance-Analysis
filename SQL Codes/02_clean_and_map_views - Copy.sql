USE HR_Analytics
-- =======================================================================
-- 1. CLEANING VIEW: HR PerformanceRating
-- =======================================================================
CREATE OR ALTER VIEW stg.vw_clean_PerformanceRating AS
WITH Deduplicated_PerformanceRating AS (
    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY Performance_ID ORDER BY Performance_ID) as rn
    FROM stg.raw_PerformanceRating
)
SELECT 
    -- Handle columns
    TRIM (Employee_ID) AS Employee_ID,
    TRIM(Performance_ID) AS Performance_ID,
    TRY_CAST(Environment_Satisfaction AS INT) AS Environment_Satisfaction,
    TRY_CAST(Job_Satisfaction AS INT) AS Job_Satisfaction,
    TRY_CAST(Relationship_Satisfaction AS INT) AS Relationship_Satisfaction,
    TRY_CAST(Training_Opportunities_Within_Year AS INT) AS Training_Opportunities_Within_Year,
    TRY_CAST(Training_Opportunities_Taken AS INT) AS Training_Opportunities_Taken,
    TRY_CAST(WorkLife_Balance AS INT) AS WorkLife_Balance,
    TRY_CAST(Self_Rating AS INT) AS Self_Rating,
    TRY_CAST(Manager_Rating AS INT) AS Manager_Rating,


    -- Date conversions (Assuming DD/MM/YYYY standard from raw file)
    TRY_CONVERT(DATE, NULLIF(NULLIF(TRIM(Review_Date), 'NULL'), ''), 101) AS Review_Date
    
FROM Deduplicated_PerformanceRating
WHERE rn = 1; -- Filter out the duplicates
GO

SELECT * FROM stg.vw_clean_PerformanceRating

-- =======================================================================
-- 2. CLEANING VIEW: Employee
-- =======================================================================
CREATE OR ALTER VIEW stg.vw_clean_Employee AS
WITH Deduplicated_Employee AS (
    -- Handles the ~1.5% duplicate rows based on the combination of Order and Product
    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY Employee_ID ORDER BY Employee_ID) as rn
    FROM stg.raw_Employee
)
SELECT 
    --  Handle columns
    TRIM (Employee_ID) AS Employee_ID,
    TRIM (First_Name) AS First_Name,
    TRIM (Last_Name) AS Last_Name,
    TRIM (Gender) AS Gender,
    TRY_CAST(Age AS INT) AS Age,
    TRIM (Business_Travel) AS Business_Travel,
    TRIM (Department) AS Department,
    TRY_CAST(Distance_From_Home AS INT) AS Distance_From_Home,
    TRIM (State) AS State,
    TRIM (Ethnicity) AS Ethnicity,
    TRY_CAST(Education AS INT) AS Education,
    TRIM (Education_Field) AS Education_Field,
    TRIM (Job_Role) AS Job_Role,
    TRIM (Marital_Status) AS Marital_Status,
    TRY_CAST(Salary AS INT) AS Salary,
    TRY_CAST(Stock_Option_Level AS INT) AS Stock_Option_Level,
    TRIM (Over_Time) AS Over_Time,
    TRY_CONVERT(DATE,NULLIF(NULLIF(TRIM(Hire_Date), 'NULL'), ''),23) AS Hire_Date,
    TRIM (Attrition) AS Attrition,
    TRY_CAST(Years_At_Company AS INT) AS Years_At_Company,
    TRY_CAST(Years_In_Most_Recent_Role AS INT) AS Years_In_Most_Recent_Role,
    TRY_CAST(YearsSince_Last_Promotion AS INT) AS YearsSince_Last_Promotion,
    TRY_CAST(Years_With_Curr_Manager AS INT) AS Years_With_Curr_Manager

    
FROM Deduplicated_Employee
WHERE rn = 1; -- Filter out the duplicates
GO

SELECT * FROM stg.vw_clean_Employee


-- =======================================================================
-- 3. CLEANING VIEW: SatisfiedLevel Table
-- =======================================================================

CREATE OR ALTER VIEW stg.vw_clean_SatisfiedLevel AS
SELECT 
  TRY_CAST(Satisfaction_ID AS INT) AS Satisfaction_ID,
  TRIM (Satisfaction_Level) AS Satisfaction_Level
FROM stg.raw_SatisfiedLevel
GO
SELECT * FROM stg.vw_clean_SatisfiedLevel
-- =======================================================================
-- 4. CLEANING VIEW: RatingLevel Table
-- =======================================================================
CREATE OR ALTER VIEW stg.vw_clean_RatingLevel AS
SELECT 
  TRY_CAST(Rating_ID AS INT) AS Rating_ID,
  TRIM (Rating_Level) AS Rating_Level
FROM stg.raw_RatingLevel
GO
SELECT * FROM stg.vw_clean_RatingLevel
-- =======================================================================
-- 5. CLEANING VIEW: EducationLevel Table
-- =======================================================================
CREATE OR ALTER VIEW stg.vw_clean_EducationLevel AS
SELECT 
  TRY_CAST(EducationLevel_ID AS INT) AS EducationLevel_ID,
  TRIM (Education_Level) AS Education_Level
FROM stg.raw_EducationLevel
GO
SELECT * FROM stg.vw_clean_EducationLevel






