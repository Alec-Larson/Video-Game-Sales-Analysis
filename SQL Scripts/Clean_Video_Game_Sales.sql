USE Video_Game_Sales;
SELECT * FROM vg_sales_raw;

-- Create staging data
CREATE TABLE vg_sales_clean AS
SELECT *
FROM vg_sales_raw;

-- Finding the missing values per column
WITH counts AS (
	SELECT
		COUNT(*) AS total_games,
        SUM(Rating IS NULL) AS missing
	FROM vg_sales_clean
)
SELECT
	total_games,
    missing,
    ROUND(missing / total_games * 100, 2) AS pct_missing
FROM counts;

---- Critic_Score missing: 51.33%
---- User_Score missing: 54.60%
---- Developer missing: 39.61%
---- Ratings missing: 40.49%

-- Investigating NULL Patterns

SELECT
	Year_of_Release,
	COUNT(*) AS total,
    SUM(User_Score IS NULL) AS missing
FROM vg_sales_clean
GROUP BY Year_of_Release;

---- Roughly half of critic scores are missing after 1995 and all missing before 1995
---- User_Score follows a similar pattern

-- Filling Year_of_Release NULLS
SELECT
    t1.`Name`,
    t1.Platform,
    t1.Year_of_Release AS current_year,
    t2.Year_of_Release AS filled_year
FROM vg_sales_clean t1
JOIN vg_sales_clean t2
  ON t1.`Name` = t2.`Name`
 AND t2.Year_of_Release IS NOT NULL
WHERE t1.Year_of_Release IS NULL;

UPDATE vg_sales_clean t1
JOIN vg_sales_clean t2
ON t1.`Name` = t2.`Name`
SET t1.Year_of_Release = t2.Year_of_Release
WHERE t1.Year_of_Release IS NULL
AND t2.Year_of_Release IS NOT NULL;

-- Checking for duplicates

SELECT
	`Name`,
    Platform,
    Year_of_Release,
	COUNT(*) AS cnt
FROM vg_sales_clean
GROUP BY `Name`, Platform, Year_of_Release
HAVING cnt > 1;

SELECT * FROM vg_sales_clean
WHERE `Name` LIKE '';

-- So we need to remove two duplicates... Madden NFL 13 and an unnamed Sega Genesis game

-- Removing Duplicates

--- One way would be to self join and only keep the larger values of global sales where
--- there is a match between Name, Platform, and Year of Release
--- Problem: Very resource intensive, initially failed on my macbook air

DELETE games1
FROM vg_sales_clean games1
INNER JOIN vg_sales_clean games2
	ON games1.`Name` = games2.`Name`
    AND games1.Platform = games2.Platform
    AND games1.Year_of_Release = games2.Year_of_Release
    AND games1.Global_Sales < games2.Global_Sales;

-- Another way: Use DELETE FROM if there are a small amount of known duplicates (only two this time)

DELETE
FROM vg_sales_clean
WHERE `Name` = 'Madden 13' AND Global_Sales < 0.2
OR `Name` = '' AND Global_Sales < 2.0;


-- Two more null values in the publisher column

UPDATE vg_sales_clean
SET
Publisher = NULL
WHERE Publisher IN ('N/A','Unknown')
;

-- Checking for publisher + genre + developer variations

SELECT DISTINCT Publisher
FROM vg_sales_clean
ORDER BY Publisher;

SELECT DISTINCT Publisher
FROM vg_sales_clean
WHERE Publisher LIKE 'SNK%';

-- Fix blank text space

UPDATE vg_sales_clean
SET Publisher = RTRIM(Publisher);

-- Fixing Publisher variations using a mapping table:

CREATE TABLE publisher_map (
	raw_publisher VARCHAR(150) PRIMARY KEY,
    fixed_publisher VARCHAR(150) NOT NULL
    )
;
INSERT INTO publisher_map (raw_publisher, fixed_publisher) VALUES
('Activision Blizzard', 'Activision'),
('Activision Value', 'Activision'),
('989 Sports', '989 Studios'),
('Ascaron Entertainment GmbH', 'Ascaron Entertainment'),
('ASCII Media Works', 'ASCII Entertainment'),
('Asmik Ace Entertainment', 'Asmik Corp'),
('Avanquest Software', 'Avanquest'),
('Bigben Interactive', 'Big Ben Interactive'),
('Codemasters Online', 'Codemasters'),
('Compile', 'Compile Heart'),
('Daedalic Entertainment', 'Daedalic'),
('EA Games', 'Electronic Arts'),
('Electronic Arts Victor', 'Electronic Arts'),
('Idea Factory International', 'Idea Factory'),
('imageepoch Inc.', 'Image Epoch'),
('Marvelous Entertainment', 'Marvelous'),
('Marvelous Games', 'Marvelous'),
('Marvelous Interactive', 'Marvelous'),
('Milestone S.r.l', 'Milestone'),
('Milestone S.r.l.', 'Milestone'),
('NEC Interchannel', 'NEC'),
('Nippon Amuse', 'Nippon'),
('Nippon Columbia', 'Nippon'),
('Nippon Ichi Software', 'Nippon'),
('Nippon Telenet', 'Nippon'),
('Paon Corporation', 'Paon'),
('Revolution (Japan)', 'Revolution Software'),
('Sony Computer Entertainment', 'Sony'),
('Sony Computer Entertainment America', 'Sony'),
('Sony Computer Entertainment Europe', 'Sony'),
('Sony Music Entertainment', 'Sony'),
('Sony Online Entertainment', 'Sony'),
('SNK Playmore', 'SNK'),
('Square', 'Square Enix'),
('SquareSoft', 'Square Enix'),
('Square EA', 'Square Enix'),
('Ubisoft Annecy', 'Ubisoft'),
('Valve Software', 'Valve');

SELECT raw_publisher, COUNT(*)
FROM publisher_map
GROUP BY raw_publisher;

SELECT
v.Publisher AS old_publisher,
m.fixed_publisher AS new_publisher
FROM vg_sales_clean v
JOIN publisher_map m
ON v.Publisher = m.raw_publisher
ORDER BY old_publisher;

UPDATE vg_sales_clean v
JOIN publisher_map m
ON v.Publisher = m.raw_publisher
SET v.Publisher = m.fixed_publisher;

-- Checking that scores are within the correct ranges

SELECT Critic_Score, User_Score
FROM vg_sales_clean
WHERE Critic_Score NOT BETWEEN 0 AND 100
OR User_Score NOT BETWEEN 0 AND 10;

-- Checking that sales numbers add up
SELECT * FROM vg_sales_clean;
WITH tot AS (
	SELECT
    (NA_Sales + EU_Sales + JP_Sales + Other_Sales) AS Total_Sales,
    Global_Sales
    FROM vg_sales_clean
    )
SELECT
Total_Sales,
Global_Sales
FROM tot
WHERE ABS(Total_Sales - Global_Sales) > 0.01;

-- There are 8 differences in value between 0.01 and 0.02 million, and none greater than
-- 0.02 million. 