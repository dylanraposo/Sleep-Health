-- Examine original dataset
SELECT * FROM dbo.health

-- Create new table to store our clean data without impacting original
CREATE TABLE healthClean (
    Person_ID INT PRIMARY KEY,
    Gender VARCHAR(10),
    Age INT,
    Occupation VARCHAR(50),
    Sleep_Duration DECIMAL(10, 2),
    Quality_of_Sleep INT,
    Physical_Activity_Level INT,
    Stress_Level INT,
    BMI_Category VARCHAR(20),
    Blood_Pressure VARCHAR(20),
    Heart_Rate INT,
    Daily_Steps INT,
    Sleep_Disorder VARCHAR(50)
);

-- Insert data into new table with proper formatting
INSERT INTO dbo.healthClean (
    Person_ID,
    Gender,
    Age,
    Occupation,
    Sleep_Duration,
    Quality_of_Sleep,
    Physical_Activity_Level,
    Stress_Level,
    BMI_Category,
    Blood_Pressure,
    Heart_Rate,
    Daily_Steps,
    Sleep_Disorder
)
SELECT
    CAST(Person_ID AS INT),
    Gender,
    CAST(Age AS INT),
    Occupation,
    CAST(Sleep_Duration AS DECIMAL(10, 2)),
    CAST(Quality_of_Sleep AS INT),
    CAST(Physical_Activity_Level AS INT),
    CAST(Stress_Level AS INT),
    BMI_Category,
    Blood_Pressure,
    CAST(Heart_Rate AS INT),
    CAST(Daily_Steps AS INT),
    Sleep_Disorder
FROM dbo.health;

-----------------------

-- See newly formatted data and refer to throughout queries
SELECT * FROM dbo.healthClean

-- Check for any duplicates
SELECT DISTINCT * FROM dbo.healthClean
		-- No duplicates

-- Remove blanks
DELETE FROM dbo.healthClean
WHERE PersonID IS NULL 
OR Gender IS NULL 
OR Age IS NULL 
OR Occupation IS NULL 
OR SleepDuration IS NULL 
OR SleepQuality IS NULL 
OR DailyPhysicalActivity IS NULL 
OR StressLevel IS NULL 
OR BMICategory IS NULL 
OR BloodPressure IS NULL 
OR HeartRate IS NULL 
OR DailySteps IS NULL 
OR SleepDisorder IS NULL;


-- Now time for EDA (Exploratory Data Analysis)

-- Record count
SELECT COUNT(*) FROM dbo.healthClean;

-- Summary statistics for age column
SELECT
    AVG(Age) AS AverageAge,
    MIN(Age) AS MinAge,
    MAX(Age) AS MaxAge
FROM dbo.healthClean;


-- Count of records by gender
SELECT Gender, COUNT(*) AS Total
FROM dbo.healthClean
GROUP BY Gender;

-- Count of records by occupation
SELECT Occupation, COUNT(*) AS Total
FROM dbo.healthClean
GROUP BY Occupation
ORDER BY Total DESC;

-- Average age by occupation
SELECT Occupation, AVG(Age) AS AverageAge
FROM dbo.healthClean
GROUP BY Occupation
ORDER BY AverageAge;


-- Calculate the average systolic and diastolic pressures (Had to do this because BloodPressure is formatted as "###/##" (VARCHAR), and we can use aggregate function on characters. 
SELECT
    AVG(CAST(SUBSTRING(BloodPressure, 1, CHARINDEX('/', BloodPressure) - 1) AS INT)) AS "Average Systolic",
    AVG(CAST(SUBSTRING(BloodPressure, CHARINDEX('/', BloodPressure) + 1, LEN(BloodPressure)) AS INT)) AS "Average Diastolic"
FROM dbo.healthClean;

-- Average age by gender
SELECT Gender, AVG(Age) AS AvgAge
FROM dbo.healthClean
GROUP BY Gender;

-- Find top 10 highest heart rates
SELECT TOP 10 PersonID, Age, HeartRate
FROM dbo.healthClean
ORDER BY HeartRate DESC;

-- Examine correlate between stress level and sleep
SELECT PersonID, StressLevel, SleepDisorder, SleepQuality
FROM dbo.healthClean
WHERE StressLevel >= 5 AND SleepDisorder != 'none'
ORDER BY StressLevel DESC;
-- Examine corrrelation between stress and sleep duration
SELECT StressLevel, AVG(SleepDuration) AS AverageSleepDuration
FROM dbo.healthClean
GROUP BY StressLevel;


-- Correlation between age and sleep quality
SELECT
  CASE
    WHEN Age < 30 THEN 'Under 30'
    WHEN Age >= 30 AND Age < 40 THEN '30-39'
    WHEN Age >= 40 AND Age < 50 THEN '40-49'
    ELSE '50 and over'
  END AS AgeGroup,
  AVG(SleepQuality) AS AvgSleepQuality
FROM dbo.healthClean
GROUP BY
  CASE
    WHEN Age < 30 THEN 'Under 30'
    WHEN Age >= 30 AND Age < 40 THEN '30-39'
    WHEN Age >= 40 AND Age < 50 THEN '40-49'
    ELSE '50 and over'
  END
  ORDER BY AvgSleepQuality;



-- Change BMI Category so we just have normal weight, overweight, and obese
UPDATE dbo.healthClean
SET BMICategory = CASE
                    WHEN BMICategory = 'Normal' THEN 'Normal Weight'
                    ELSE BMICategory
                 END;

-- How occupation impacts sleep and stress
SELECT TOP 5 Occupation, AVG(SleepDuration) AS AvgSleepDuration, AVG(StressLevel) AS AvgStress
FROM dbo.healthClean
GROUP BY Occupation
ORDER BY AvgSleepDuration DESC;

-- Correlation from BMI to sleep per gender
SELECT BMICategory, Gender, AVG(SleepDuration) AS AvgSleepDuration, AVG(SleepQuality) AS SleepQuality
FROM dbo.healthClean
GROUP BY BMICategory, Gender
ORDER BY AvgSleepDuration;

-- Correlation between occupation and physical activity
SELECT Occupation, AVG(DailyPhysicalActivity) AS AvgActivityLevel
FROM dbo.healthClean
WHERE Age < 40
GROUP BY Occupation
ORDER BY AvgActivityLevel;


-- With data cleaned and various insights gained, we went to Tableau to visualize findings. 


