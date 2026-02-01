--Create + Load Database
CREATE SCHEMA Video_Game_Sales;
USE Video_Game_Sales;

--Create + Load Data Into Table
CREATE TABLE vg_sales_raw (
    `Name` VARCHAR(250),
    Platform VARCHAR(100),
    Year_of_Release INT NULL,
    Genre VARCHAR(100),
    Publisher VARCHAR(100),
    NA_Sales DECIMAL(6, 2),
    EU_Sales DECIMAL(6, 2),
    JP_Sales DECIMAL(6, 2),
    Other_Sales DECIMAL(6, 2),
    Global_Sales DECIMAL(6, 2),
    Critic_Score INT NULL,
    Critic_Count INT NULL,
    User_Score DECIMAL(2, 1) NULL,
    User_Count INT NULL,
    Developer VARCHAR(250) NULL,
    Rating VARCHAR(100) NULL
);

LOAD DATA LOCAL INFILE '/Video_Games_Sales_as_at_22_Dec_2016.csv' INTO TABLE vg_sales_raw 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES (
    `Name`,
    Platform,
    @Year_of_Release,
    Genre,
    Publisher,
    NA_Sales,
    EU_Sales,
    JP_Sales,
    Other_Sales,
    Global_Sales,
    @Critic_Score,
    @Critic_Count,
    @User_Score,
    @User_Count,
    @Developer,
    @Rating,
    @Extra1,
    @Extra2
)
SET Year_of_Release = NULLIF(@Year_of_Release, 'N/A'),
    Critic_Score = NULLIF(@Critic_Score, ''),
    Critic_Count = NULLIF(@Critic_Count, ''),
    User_Score = IF(
        @User_Score = ''
        OR @User_Score = 'tbd',
        NULL,
        @User_Score
    ),
    User_Count = NULLIF(@User_Count, ''),
    Developer = NULLIF(@Developer, ''),
    Rating = NULLIF(@Rating, '');