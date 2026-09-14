USE HR_Analytics;
GO

CREATE SCHEMA dw;
GO

-------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS dw.FactPerformanceRating;
DROP TABLE IF EXISTS dw.DimRatingLevel;
DROP TABLE IF EXISTS dw.DimSatisfiedLevel;
DROP TABLE IF EXISTS dw.DimEmployee;
DROP TABLE IF EXISTS dw.DimDate;
GO
---------------------------------------------------------------------------------
SELECT * FROM dw.FactPerformanceRating;
SELECT * FROM dw.DimRatingLevel;
SELECT * FROM dw.DimSatisfiedLevel;
SELECT * FROM dw.DimEmployee;
SELECT * FROM dw.DimDate;
-- =====================================================================
-- 1. CREATE DIMENSION TABLES
-- =====================================================================
-- Dim Date
CREATE TABLE dw.DimDate
(
    Date_Key             INT          NOT NULL,
    FullDate            DATE          NOT NULL,
    DayNumberOfMonth    TINYINT       NOT NULL,
    DayNumberOfWeek     TINYINT       NOT NULL, -- Monday = 1, Sunday = 7
    DayName             NVARCHAR(20)  NOT NULL,
    MonthNumber         TINYINT       NOT NULL,
    MonthName           NVARCHAR(20)  NOT NULL,
    QuarterNumber       TINYINT       NOT NULL,
    QuarterName         CHAR(2)       NOT NULL,
    CalendarYear        SMALLINT      NOT NULL,
    YearMonth           CHAR(7)       NOT NULL,
    IsWeekend           BIT           NOT NULL,

    CONSTRAINT PK_DimDate PRIMARY KEY (Date_Key),
    CONSTRAINT UQ_DimDate_FullDate UNIQUE (FullDate)
);
GO
SELECT * FROM dw.DimDate
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
-- Dim Employee
CREATE TABLE dw.DimEmployee
(
    Employee_ID                 INT IDENTITY(1,1) NOT NULL,
    EmployeeCode                NVARCHAR(50)      NOT NULL,
    FirstName                   NVARCHAR(50)      NULL,
    LastName                    NVARCHAR(50)      NULL,
    FullName                    NVARCHAR(110)     NULL,
    Gender                      NVARCHAR(50)      NULL,
    Age                         INT               NULL,
    AgeGroup                    NVARCHAR(20)      NULL,
    BusinessTravel              NVARCHAR(50)      NULL,
    DistanceFromHome            INT               NULL,
    State                       NVARCHAR(10)      NULL,
    Ethnicity                   NVARCHAR(50)      NULL,
    MaritalStatus               NVARCHAR(20)      NULL,
    Salary                      DECIMAL(10,2)     NULL,
    StockOptionLevel            INT               NULL,
    OverTime                    NVARCHAR(10)      NULL,
    HireDate                    DATE              NULL,
    Attrition                   NVARCHAR(10)      NULL,
    YearsAtCompany              INT               NULL,
    YearsInMostRecentRole       INT               NULL,
    YearsSinceLastPromotion     INT               NULL,
    YearsWithCurrentManager     INT               NULL,
    DepartmentName              NVARCHAR(50)      NULL,
    EducationLevel              NVARCHAR(50)      NULL,
    EducationField              NVARCHAR(50)      NULL,
    JobRole                     NVARCHAR(50)      NULL,

    CONSTRAINT PK_DimEmployee PRIMARY KEY (Employee_ID),
    CONSTRAINT UQ_DimEmployee_EmployeeCode UNIQUE (EmployeeCode)
);
GO
SELECT * FROM dw.DimEmployee
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Dim SatisfiedLevel
CREATE TABLE dw.DimSatisfiedLevel
(
    Satisfaction_ID             INT IDENTITY(1,1) NOT NULL,
    SatisfactionLevel           NVARCHAR(50)      NOT NULL,

    CONSTRAINT PK_DimSatisfiedLevel PRIMARY KEY (Satisfaction_ID)
);
GO
SELECT * FROM dw.DimSatisfiedLevel
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Dim RatingLevel
CREATE TABLE dw.DimRatingLevel
(
    Rating_ID                   INT IDENTITY(1,1) NOT NULL,
    RatingLevel                 NVARCHAR(50)      NOT NULL,

    CONSTRAINT PK_DimRatingLevel PRIMARY KEY (Rating_ID)
);
GO
SELECT * FROM dw.DimRatingLevel

-- =====================================================================
-- 2. CREATE FACT TABLE
-- =====================================================================
-- Fact PerformanceRating
CREATE TABLE dw.FactPerformanceRating
(
    PerformanceRating_ID            INT IDENTITY(1,1) NOT NULL,
    PerformanceCode                 NVARCHAR(50)      NOT NULL,
    Employee_ID                     INT               NOT NULL,
    ReviewDateKey                   INT               NOT NULL,

    EnvironmentSatisfactionKey      INT               NOT NULL,
    JobSatisfactionKey              INT               NOT NULL,
    RelationshipSatisfactionKey     INT               NOT NULL,
    WorkLifeBalanceKey              INT               NOT NULL,

    SelfRatingKey                   INT               NOT NULL,
    ManagerRatingKey                INT               NOT NULL,

    TrainingOpportunitiesWithinYear INT               NULL,
    TrainingOpportunitiesTaken      INT               NULL,
    ReviewCount                     INT               NOT NULL
   
CONSTRAINT DF_FactPerformanceRating_ReviewCount DEFAULT (1),

CONSTRAINT PK_FactPerformanceRating
     PRIMARY KEY (PerformanceRating_ID),

CONSTRAINT UQ_FactPerformanceRating_PerformanceCode
     UNIQUE (PerformanceCode),

CONSTRAINT UQ_FactPerformanceRating_Employee_ReviewDate
     UNIQUE (Employee_ID, ReviewDateKey),

CONSTRAINT FK_FactPerformanceRating_Employee
     FOREIGN KEY (Employee_ID)
     REFERENCES dw.DimEmployee (Employee_ID),

CONSTRAINT FK_FactPerformanceRating_ReviewDate
     FOREIGN KEY (ReviewDateKey)
     REFERENCES dw.DimDate (Date_Key),

CONSTRAINT FK_FactPerformanceRating_EnvironmentSatisfaction
        FOREIGN KEY (EnvironmentSatisfactionKey)
        REFERENCES dw.DimSatisfiedLevel (Satisfaction_ID),

    CONSTRAINT FK_FactPerformanceRating_JobSatisfaction
        FOREIGN KEY (JobSatisfactionKey)
        REFERENCES dw.DimSatisfiedLevel (Satisfaction_ID),

    CONSTRAINT FK_FactPerformanceRating_RelationshipSatisfaction
        FOREIGN KEY (RelationshipSatisfactionKey)
        REFERENCES dw.DimSatisfiedLevel (Satisfaction_ID),

    CONSTRAINT FK_FactPerformanceRating_WorkLifeBalance
        FOREIGN KEY (WorkLifeBalanceKey)
        REFERENCES dw.DimSatisfiedLevel (Satisfaction_ID),

    CONSTRAINT FK_FactPerformanceRating_SelfRating
        FOREIGN KEY (SelfRatingKey)
        REFERENCES dw.DimRatingLevel (Rating_ID),

    CONSTRAINT FK_FactPerformanceRating_ManagerRating
        FOREIGN KEY (ManagerRatingKey)
        REFERENCES dw.DimRatingLevel (Rating_ID),

    CONSTRAINT CK_FactPerformanceRating_ReviewCount
        CHECK (ReviewCount = 1)
);
GO

-- =====================================================================
-- 3. LOAD DIMENSIONS
-- =====================================================================


SET NOCOUNT ON;
SET XACT_ABORT ON;
SET DATEFIRST 1;      -- Monday = 1
SET LANGUAGE English; -- English month/day names

BEGIN TRY
    BEGIN TRANSACTION;

    ---------------------------------------------------------------------
    -- To Prevent Load data Twice
    ---------------------------------------------------------------------
    IF EXISTS (SELECT 1 FROM dw.FactPerformanceRating)
       OR EXISTS (SELECT 1 FROM dw.DimEmployee)
       OR EXISTS (SELECT 1 FROM dw.DimDate)
       OR EXISTS (SELECT 1 FROM dw.DimSatisfiedLevel)
       OR EXISTS (SELECT 1 FROM dw.DimRatingLevel)
    BEGIN
        THROW 50001,
              'DW tables already contain data. The loading process was stopped.',
              1;
    END;


    -- =================================================================
    -- 1. LOAD dw.DimDate
    -- =================================================================

    DECLARE @StartDate DATE;
    DECLARE @EndDate   DATE;

    SELECT
        @StartDate =
            DATEFROMPARTS(YEAR(MIN(Review_Date)), 1, 1),

        @EndDate =
            DATEFROMPARTS(YEAR(MAX(Review_Date)), 12, 31)
    FROM ods.PerformanceRating
    WHERE Review_Date IS NOT NULL;

    IF @StartDate IS NULL OR @EndDate IS NULL
    BEGIN
        THROW 50002,
              'No valid Review_Date values were found in ods.PerformanceRating.',
              1;
    END;

    WITH DateGenerator AS
    (
        SELECT @StartDate AS FullDate

        UNION ALL

        SELECT DATEADD(DAY, 1, FullDate)
        FROM DateGenerator
        WHERE FullDate < @EndDate
    )
    INSERT INTO dw.DimDate
    (
        Date_Key,
        FullDate,
        DayNumberOfMonth,
        DayNumberOfWeek,
        DayName,
        MonthNumber,
        MonthName,
        QuarterNumber,
        QuarterName,
        CalendarYear,
        YearMonth,
        IsWeekend
    )
    SELECT
        CONVERT(INT, CONVERT(CHAR(8), FullDate, 112)) AS Date_Key,
        FullDate,
        DAY(FullDate)                                AS DayNumberOfMonth,
        DATEPART(WEEKDAY, FullDate)                  AS DayNumberOfWeek,
        DATENAME(WEEKDAY, FullDate)                  AS DayName,
        MONTH(FullDate)                              AS MonthNumber,
        DATENAME(MONTH, FullDate)                    AS MonthName,
        DATEPART(QUARTER, FullDate)                  AS QuarterNumber,
        CONCAT('Q', DATEPART(QUARTER, FullDate))     AS QuarterName,
        YEAR(FullDate)                               AS CalendarYear,
        CONVERT(CHAR(7), FullDate, 120)              AS YearMonth,
        CASE
            WHEN DATEPART(WEEKDAY, FullDate) IN (6, 7)
                THEN 1
            ELSE 0
        END                                          AS IsWeekend
    FROM DateGenerator
    OPTION (MAXRECURSION 0);


    -- =================================================================
    -- 2. LOAD dw.DimSatisfiedLevel
    -- =================================================================

    INSERT INTO dw.DimSatisfiedLevel
    (
        SatisfactionLevel
    )
    SELECT DISTINCT
        LTRIM(RTRIM(Satisfaction_Level))
    FROM ods.SatisfiedLevel
    WHERE NULLIF(LTRIM(RTRIM(Satisfaction_Level)), '') IS NOT NULL;


    -- =================================================================
    -- 3. LOAD dw.DimRatingLevel
    -- =================================================================

    INSERT INTO dw.DimRatingLevel
    (
        RatingLevel
    )
    SELECT DISTINCT
        LTRIM(RTRIM(Rating_Level))
    FROM ods.RatingLevel
    WHERE NULLIF(LTRIM(RTRIM(Rating_Level)), '') IS NOT NULL;


    -- =================================================================
    -- 4. LOAD dw.DimEmployee
    -- =================================================================

    INSERT INTO dw.DimEmployee
    (
        EmployeeCode,
        FirstName,
        LastName,
        FullName,
        Gender,
        Age,
        AgeGroup,
        BusinessTravel,
        DistanceFromHome,
        State,
        Ethnicity,
        MaritalStatus,
        Salary,
        StockOptionLevel,
        OverTime,
        HireDate,
        Attrition,
        YearsAtCompany,
        YearsInMostRecentRole,
        YearsSinceLastPromotion,
        YearsWithCurrentManager,
        DepartmentName,
        EducationLevel,
        EducationField,
        JobRole
    )
    SELECT
        LTRIM(RTRIM(e.Employee_Code)) AS EmployeeCode,
        NULLIF(LTRIM(RTRIM(e.First_Name)), '') AS FirstName,
        NULLIF(LTRIM(RTRIM(e.Last_Name)), '')  AS LastName,

        NULLIF(
            LTRIM(RTRIM(
                CONCAT(
                    NULLIF(LTRIM(RTRIM(e.First_Name)), ''),
                    ' ',
                    NULLIF(LTRIM(RTRIM(e.Last_Name)), '')
                )
            )),
            ''
        ) AS FullName,

        e.Gender,
        e.Age,

        CASE
            WHEN e.Age IS NULL THEN NULL
            WHEN e.Age < 25    THEN 'Under 25'
            WHEN e.Age <= 34   THEN '25-34'
            WHEN e.Age <= 44   THEN '35-44'
            WHEN e.Age <= 54   THEN '45-54'
            ELSE '55+'
        END AS AgeGroup,

        e.Business_Travel,
        e.Distance_From_Home,
        e.State,
        e.Ethnicity,
        e.Marital_Status,
        e.Salary,
        e.Stock_Option_Level,
        e.Over_Time,
        e.Hire_Date,
        e.Attrition,
        e.Years_At_Company,
        e.Years_In_Most_Recent_Role,
        e.YearsSince_Last_Promotion,
        e.Years_With_Curr_Manager,
        dep.Department_Name,
        edu.Education_Level,
        ef.Education_Field,
        jr.Job_Role

    FROM ods.Employee AS e

    LEFT JOIN ods.Departments AS dep
        ON e.Department_ID = dep.Department_ID

    LEFT JOIN ods.Education_level AS edu
        ON e.Education_Level_ID = edu.EducationLevel_ID

    LEFT JOIN ods.Education_Field AS ef
        ON e.Education_Field_ID = ef.Education_Field_ID

    LEFT JOIN ods.Job_Role AS jr
        ON e.Job_Role_ID = jr.Job_Role_ID

    WHERE NULLIF(LTRIM(RTRIM(e.Employee_Code)), '') IS NOT NULL;


    -- =================================================================
    -- 5. LOAD dw.FactPerformanceRating
    -- =================================================================

    DECLARE @SourceFactCount INT;
    DECLARE @InsertedFactCount INT;

    SELECT @SourceFactCount = COUNT(*)
    FROM ods.PerformanceRating;

    INSERT INTO dw.FactPerformanceRating
    (
        PerformanceCode,
        Employee_ID,
        ReviewDateKey,

        EnvironmentSatisfactionKey,
        JobSatisfactionKey,
        RelationshipSatisfactionKey,
        WorkLifeBalanceKey,

        SelfRatingKey,
        ManagerRatingKey,

        TrainingOpportunitiesWithinYear,
        TrainingOpportunitiesTaken,
        ReviewCount
    )
    SELECT
        pr.Performance_Code,
        de.Employee_ID,
        dd.Date_Key,

        dsEnvironment.Satisfaction_ID,
        dsJob.Satisfaction_ID,
        dsRelationship.Satisfaction_ID,
        dsWorkLife.Satisfaction_ID,

        drSelf.Rating_ID,
        drManager.Rating_ID,

        pr.Training_Opportunities_Within_Year,
        pr.Training_Opportunities_Taken,
        1 AS ReviewCount

    FROM ods.PerformanceRating AS pr

    INNER JOIN ods.Employee AS oe    
        ON pr.Employee_ID = oe.Employee_ID

    INNER JOIN dw.DimEmployee AS de
        ON de.EmployeeCode = oe.Employee_Code

    INNER JOIN dw.DimDate AS dd
        ON dd.FullDate = pr.Review_Date

    INNER JOIN ods.SatisfiedLevel AS osEnvironment
        ON pr.Environment_Satisfaction =
           osEnvironment.Satisfaction_Level_ID

    INNER JOIN dw.DimSatisfiedLevel AS dsEnvironment
        ON dsEnvironment.SatisfactionLevel =
           osEnvironment.Satisfaction_Level

    INNER JOIN ods.SatisfiedLevel AS osJob
        ON pr.Job_Satisfaction =
           osJob.Satisfaction_Level_ID

    INNER JOIN dw.DimSatisfiedLevel AS dsJob
        ON dsJob.SatisfactionLevel =
           osJob.Satisfaction_Level

    INNER JOIN ods.SatisfiedLevel AS osRelationship
        ON pr.Relationship_Satisfaction =
           osRelationship.Satisfaction_Level_ID

    INNER JOIN dw.DimSatisfiedLevel AS dsRelationship
        ON dsRelationship.SatisfactionLevel =
           osRelationship.Satisfaction_Level

    INNER JOIN ods.SatisfiedLevel AS osWorkLife
        ON pr.WorkLife_Balance =
           osWorkLife.Satisfaction_Level_ID

    INNER JOIN dw.DimSatisfiedLevel AS dsWorkLife
        ON dsWorkLife.SatisfactionLevel =
           osWorkLife.Satisfaction_Level

    INNER JOIN ods.RatingLevel AS orSelf
        ON pr.Self_Rating = orSelf.Rating_Level_ID

    INNER JOIN dw.DimRatingLevel AS drSelf
        ON drSelf.RatingLevel = orSelf.Rating_Level

    INNER JOIN ods.RatingLevel AS orManager
        ON pr.Manager_Rating = orManager.Rating_Level_ID

    INNER JOIN dw.DimRatingLevel AS drManager
        ON drManager.RatingLevel = orManager.Rating_Level

    WHERE NULLIF(LTRIM(RTRIM(pr.Performance_Code)), '') IS NOT NULL
      AND pr.Review_Date IS NOT NULL;
--------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- To ensure Load All Data

    SET @InsertedFactCount = @@ROWCOUNT;
    IF @InsertedFactCount <> @SourceFactCount
    BEGIN
        THROW 50004,
              'Some performance records were not loaded because a dimension key or required value could not be matched.',
              1;
    END;


    COMMIT TRANSACTION;

    PRINT 'Data warehouse loaded successfully.';
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    SELECT
        ERROR_NUMBER()    AS ErrorNumber,
        ERROR_MESSAGE()   AS ErrorMessage,
        ERROR_LINE()      AS ErrorLine,
        ERROR_PROCEDURE() AS ErrorProcedure;

    THROW;

END CATCH;
GO
