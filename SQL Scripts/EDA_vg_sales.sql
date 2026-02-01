USE Video_Game_Sales;
SELECT *
FROM vg_sales_clean;

-- Investigating and creating views

--- Sales by region:

SELECT SUM(NA_Sales) NA,
    SUM(JP_Sales) JP,
    SUM(EU_Sales) EU,
    SUM(Other_Sales) Other
FROM vg_sales_clean;

SELECT Platform,
    SUM(NA_Sales) NA,
    SUM(JP_Sales) JP,
    SUM(EU_Sales) EU,
    SUM(Other_Sales) Other
FROM vg_sales_clean
GROUP BY Platform;

CREATE VIEW vg_platform_sales_region AS
SELECT Platform,
    SUM(NA_Sales) NA,
    SUM(JP_Sales) JP,
    SUM(EU_Sales) EU,
    SUM(Other_Sales) Other
FROM vg_sales_clean
GROUP BY Platform;

SELECT *
FROM vg_platform_sales_region;

CREATE VIEW vg_sales_year AS
SELECT Year_of_Release,
    SUM(NA_Sales) NA,
    SUM(JP_Sales) JP,
    SUM(EU_Sales) EU,
    SUM(Other_Sales) Other
FROM vg_sales_clean
WHERE Year_of_Release IS NOT NULL
GROUP BY Year_of_Release;

SELECT *
FROM vg_sales_year;

--- Do critic scores correlate with sales numbers?

CREATE VIEW vg_criticscore_sales_buckets AS WITH Scored AS (
    SELECT CASE
            WHEN Critic_Score BETWEEN 0 AND 49 THEN '0-49'
            WHEN Critic_Score BETWEEN 50 AND 69 THEN '50-69'
            WHEN Critic_Score BETWEEN 70 AND 79 THEN '70-79'
            WHEN Critic_Score BETWEEN 80 AND 89 THEN '80-89'
            WHEN Critic_Score BETWEEN 90 AND 100 THEN '90-100'
        END AS Critic_Bucket,
        Global_Sales
    FROM vg_sales_clean
    WHERE Critic_Score IS NOT NULL
)
SELECT Critic_Bucket,
    AVG(Global_Sales) Avg_Global_Sales,
    COUNT(*) Game_Count
FROM Scored
GROUP BY Critic_Bucket
ORDER BY Critic_Bucket;

SELECT *
FROM vg_criticscore_sales_buckets;

---- Critic Buckets using NTILEs

CREATE VIEW vg_criticscore_sales_quantiles AS WITH Ranked AS (
    SELECT Critic_Score,
        Global_Sales,
        NTILE(5) OVER (
            ORDER BY Critic_Score
        ) AS Critic_Quantile
    FROM vg_sales_clean
    WHERE Critic_Score IS NOT NULL
)
SELECT Critic_Quantile,
    AVG(Global_Sales) AS Avg_Global_Sales,
    COUNT(*) AS Game_Count,
    MIN(Critic_Score) AS Min_Score,
    MAX(Critic_Score) AS Max_Score
FROM Ranked
GROUP BY Critic_Quantile
ORDER BY Critic_Quantile;

SELECT *
FROM vg_criticscore_sales_quantiles;

--- Do user scores correlate with sales numbers?
DROP VIEW IF EXISTS vg_userscore_sales_buckets;
CREATE VIEW vg_userscore_sales_buckets AS WITH Scored AS (
    SELECT CASE
            WHEN User_Score BETWEEN 0.0 AND 4.9 THEN '0.0-4.9'
            WHEN User_Score BETWEEN 5.0 AND 6.9 THEN '5.0-6.9'
            WHEN User_Score BETWEEN 7.0 AND 7.9 THEN '7.0-7.9'
            WHEN User_Score BETWEEN 8.0 AND 8.9 THEN '8.0-8.9'
            WHEN User_Score BETWEEN 9.0 AND 10.0 THEN '9.0-10.0'
        END AS User_Bucket,
        Global_Sales
    FROM vg_sales_clean
    WHERE User_Score IS NOT NULL
)
SELECT User_Bucket,
    AVG(Global_Sales) Avg_Global_Sales,
    COUNT(*) Game_Count
FROM Scored
GROUP BY User_Bucket
ORDER BY User_Bucket;

SELECT *
FROM vg_userscore_sales_buckets;

---- User Buckets using NTILEs

CREATE VIEW vg_userscore_sales_quantiles AS WITH Ranked AS (
    SELECT User_Score,
        Global_Sales,
        NTILE(5) OVER (
            ORDER BY User_Score
        ) AS User_Quantile
    FROM vg_sales_clean
    WHERE User_Score IS NOT NULL
)
SELECT User_Quantile,
    AVG(Global_Sales) AS Avg_Global_Sales,
    COUNT(*) AS Game_Count,
    MIN(User_Score) AS Min_Score,
    MAX(User_Score) AS Max_Score
FROM Ranked
GROUP BY User_Quantile
ORDER BY User_Quantile;

SELECT *
FROM vg_userscore_sales_quantiles;

--- Video Game Sales Over Time (Handheld vs Console)

---- Creating the handheld/home_console column

SELECT DISTINCT Platform
FROM vg_sales_clean;

ALTER TABLE vg_sales_clean
ADD COLUMN Platform_Type VARCHAR(100);
UPDATE vg_sales_clean
SET Platform_Type = CASE
        -- Home consoles
        WHEN Platform IN (
            'PS',
            'PS2',
            'PS3',
            'PS4',
            '2600',
            'PC',
            'GC',
            'N64',
            'DC',
            'NG',
            'PCFX',
            'TG16',
            '3DO',
            'SCD',
            'SAT',
            'GEN'
        ) THEN 'Home'
        WHEN Platform LIKE 'Wii%' THEN 'Home'
        WHEN Platform LIKE 'X%' THEN 'Home'
        WHEN Platform LIKE '%NES' THEN 'Home' 
        -- Handhelds
        WHEN Platform IN ('GG', 'PSP', 'PSV') THEN 'Handheld'
        WHEN Platform LIKE 'GB%' THEN 'Handheld'
        WHEN Platform LIKE '%DS' THEN 'Handheld'
        ELSE NULL
    END;

SELECT Platform_Type,
    COUNT(*) AS Game_Count
FROM vg_sales_clean
GROUP BY Platform_Type;

CREATE VIEW vg_platformtype_sales_year AS
SELECT Year_of_Release,
    Platform_Type,
    SUM(Global_Sales) Global_Sales
FROM vg_sales_clean
WHERE Platform IS NOT NULL
    AND Year_of_Release IS NOT NULL
GROUP BY Year_of_Release,
    Platform_Type
ORDER BY Year_of_Release,
    Platform_Type;

SELECT *
FROM vg_platformtype_sales_year;

--- Genre Sales by Region
CREATE VIEW vg_genre_sales_region AS
SELECT Genre,
    SUM(NA_Sales) NA,
    SUM(JP_Sales) JP,
    SUM(EU_Sales) EU,
    SUM(Other_Sales) Other
FROM vg_sales_clean
GROUP BY Genre;
SELECT *
FROM vg_genre_sales_region;

--- Select Genre Sales Numbers

SELECT SUM(Global_Sales)
FROM vg_sales_clean
WHERE Genre = 'Action';

SELECT SUM(Global_Sales)
FROM vg_sales_clean
WHERE Genre = 'Sports';

SELECT SUM(Global_Sales)
FROM vg_sales_clean
WHERE Genre = 'Strategy';

SELECT SUM(Global_Sales)
FROM vg_sales_clean
WHERE Genre = 'Puzzle';

--- Total Nintendo Sales:

SELECT SUM(Global_Sales)
FROM vg_sales_clean
WHERE Platform IN ('NES','SNES','GB','N64','GBA','GC','DS','3DS','Wii','Wii U');

--- Total Playstation Sales:

SELECT SUM(Global_Sales)
FROM vg_sales_clean
WHERE Platform IN ('PS','PS2','PSP','PS3','PSV','PS4');

--- Total Xbox Sales:

SELECT SUM(Global_Sales)
FROM vg_sales_clean
WHERE Platform IN ('XB','X360','XOne');

--- Sales by year since platforms' launch

SELECT Platform,
    MIN(Year_of_Release) AS Launch_Year
FROM vg_sales_clean
GROUP BY Platform;

CREATE VIEW vg_platformyear_sales AS WITH Platform_Launch AS (
    SELECT Platform,
        MIN(Year_of_Release) AS Launch_Year
    FROM vg_sales_clean
    WHERE Year_of_Release IS NOT NULL
    GROUP BY Platform
),
Lifecycle AS (
    SELECT v.Platform,
        v.Year_of_Release,
        (v.Year_of_Release - p.Launch_Year + 1) AS Platform_Year,
        v.Global_Sales
    FROM vg_sales_clean v
        JOIN Platform_Launch p ON v.Platform = p.Platform
    WHERE Year_of_Release IS NOT NULL
)
SELECT *
FROM Lifecycle
ORDER BY Platform,
    Year_of_Release;
    
SELECT *
FROM vg_platformyear_sales;