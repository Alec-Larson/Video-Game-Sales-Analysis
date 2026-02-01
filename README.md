# The Business of Gaming: An Analysis of Video Game Software Sales (1980 - 2016)

## Introduction + Project Overview

The video games industry is a volatile one. Every major leap in real time graphics comes with demand for improved hardware, leading to a cycle of new console launches every six to ten years. Every console manufacturer has had varying degrees of success throughout the console generations. This analysis explores **global video game software sales** beginning with the first generation of home console gaming in the 1980s and aims to uncover platform trends, the impact of review scores on sales, and the success of the games industry in regional markets. The data is sourced from [vgchartz.com](https://www.vgchartz.com/) and was originally scraped by [GregorySmith](https://www.kaggle.com/gregorut)

## Interactive Dashboard

**View the dashboard here!**
[![Tableau Public - Video Game Software Sales (1980 - 2016)](/images/VG_Sales_Thumbnail.png)](https://public.tableau.com/views/VideoGameSoftwareSales1980-2016/VGSalesDash?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

This dashboard allows interactive exploration of regional sales, critic/user score trends, and sales for individual console platforms over time.

## Skills and Tools Used

- MySQL
- Data Visualization With Tableau Public
- Microsoft Excel

## Data Source

Sales data sourced from [Kaggle](https://www.kaggle.com/datasets/gregorut/videogamesales) (originally compiled by GregorySmith),
covering global video game sales from 1980–2016.

## Loading the CSV

Two steps of the data cleaning process can be completed when loading the data into SQL. First, data types can be corrected from the raw data. Take the review score columns for example, which can be changed from text to a more correct decimal data type. Second, rows sometimes contain '' and 'tbd' which can be set to NULL (see the User_Score column example below).

<details>
<summary>View SQL User_Score Example</summary>

```sql
SET User_Score = IF(
        @User_Score = ''
        OR @User_Score = 'tbd',
        NULL,
        @User_Score
    )
```

</details>

<br>

Also in the csv are two blank columns, which I eliminate by creating two extra variables, then forgoing setting them equal to any values.

## Further Cleanup 🧹

There are certain NULLs that can be filled in the Year_of_Release column. These can be filled in certain cases when a value exists for the same game release on a different platform:

<details>
<summary>Filling NULLs in Year Column</summary>

```sql
UPDATE vg_sales_clean t1
JOIN vg_sales_clean t2
ON t1.`Name` = t2.`Name`
SET t1.Year_of_Release = t2.Year_of_Release
WHERE t1.Year_of_Release IS NULL
AND t2.Year_of_Release IS NOT NULL;
```

</details>

<br>

The largest hurdle to clear when it comes to cleaning this data set is that game publisher names vary across listings. For example, 'Electronic Arts' may also have the variant 'EA'. To correct for this, I use a mapping table and manually input standardized publisher names, then set the correct values with a self join:

<details>
<summary>Fixing publisher variation with join</summary>

```sql
UPDATE vg_sales_clean v
JOIN publisher_map m
ON v.Publisher = m.raw_publisher
SET v.Publisher = m.fixed_publisher;
```

</details>

## Exploratory Analysis

To investigate the data, I first create a VIEW with SQL. The MySQL database can be used directly in Tableau desktop depending on the version. For this project I use Tableau public, so each SQL VIEW is first converted to an Excel sheet – found in the cleaned data folder within the repository – then uploaded to Tableau locally. For the full interactive dashboard, see the Tableau workbook Video_Game_Sales.twb.

### Total Software Sales (1980 - 2016)

The following are the total software sales across all platforms:

![BAN_Tot_Sales](/images/BAN_Tot_Sales.png)

![BAN_HoC_Sales](/images/BAN_HoC_Sales.png)

![BAN_HaC_Sales](/images/BAN_HaC_Sales.png)

While the handheld games industry sold almost two billion units, it never reached the heights of the home console industry.

Home console sales (blue) were only contested by the handheld market (green) in the early 1990s and mid 2000s

![vg_platform_type_sales](/images/vg_pt_sales.png)

### Main Platform Publishers

Since the 2000s, Nintendo, Playstation, and Xbox (the Big Three) have been produced the three most popular home console platforms of each generation.

Nintendo was one of the original home console producers in the early days of gaming. Despite having a headstart on Sony's Playstation consoles, lifetime software sales for Nintendo platforms are roughly 140 million units behind Playstation at 3.42 Billion units

![Nintendo](/images/Nintendo_Sales.png)

As of 2016, Playstation was the all time leader in software sold on their platforms at 3.59 Billion units. The PS1 Launched eight years after Nintendo's first console (The Nintendo Entertainment System)

![Sony](/images/Playstation_Sales.png)

Xbox joined the competition in 2000 with the launch of the original Xbox in 2001. Their lifetime software sales on their platforms are dwarfed by the Nintendo and Sony with 1.39 Billion units sold.

![Xbox](/images/Xbox_Sales.png)

With the success of Nintendo's Switch console, it's possible that Nintendo has reclaimed the lifetime sales crown in recent years. A future analysis of software sales with an up to date scrape of vgchartz.com could answer this.

### The Most Popular Genres

In the vgchartz data, only one genre is assigned to each listing. Since many games cannot be defined under just one genre (e.g. adventure games tend to have action elements) it is difficult to find a precise ranking of genre sales. However, there are certainly some genres that are more popular than others by a wide margin:

- Action: ~1.75B Units
- Sports: ~1.33B Units

Likewise, certain genres are clearly less popular:

- Strategy: ~174.50M Units
- Puzzle: ~243.02M Units

![Genre_Pie](/images/Genre_Pie.png)

### Critic/User Score + Sales Correlations

By dividing review scores into fixed quantiles, the average number of sales for each quantile can be calculated. This number can then be compared across quantiles and whether or not a correlation exists between review scores and game sales can be determined. Before looking at these numbers, it was my expectation that games falling in the 75 - 80 range would sell the highest. The Call of Duty games as well as annual sports games can often fall into this range. While iterative, these franchises tend to sell well with each subsequent release.

The following bar charts reveal the average sales for games in each quantile for both critic and user scores (Metacritic)

![Critics](/images/Critic_Sales_Quantiles.png)

![Users](/images/User_Sales_Quantiles.png)

My findings show that games scoring above an 81 or above on Metacritic have dramatically higher average sales than the next highest quantile. Similarly, user scores of 8.4 or above have the highest average sales. For these user scores, there is still a positive correlation with average sales, though it is not as dramatic as withh critic scores. A possible interpretation of these results could be that consumers tend to value critic scores more heavily when spending their money on a video game. Further analysis might consider how this relationship compares with other industries e.g. movie ticket sales.

It should be noted that these relationships are still found when using fixed score intervals rather than quantiles as illustrated by the following bar charts:

![Critics_Fixed](/images/Critic_Sales_Fixed.png)

![Users_Fixed](/images/User_Sales_Fixed.png)

Using fixed intervals, the correlation between critic scores and average sales becomes even more dramatic, with the highest score interval averaging well over 2 millions units sold.

## The Games Industry Today + Future Analysis Recommendations

Since 2016, the games industry has been greatly shaken up. Nintendo rebounded from the poor sales numbers in the Wii U era by introducing the Switch, a brand new hybrid type of console. If the analysis in this project were to be extended to include the Nintendo Switch era, investigating handheld software sales would no longer be relevant. There is no longer a broadly adopted handheld system in this current generation, and I would argue that the Switch is marketed by Nintendo as a home console, despite its hybrid nature.

Another more recent change is the decline of video games exclusive to only one platform. Xbox's game developers have transitioned to developing games across all platforms including Nintendo and Playstation, meaning that owning an Xbox is no longer the only way to experience Xbox games. Similarly, Sony's first party studios have been developing games for PC, though on home consoles their Playstation exclusivity remains.

These shake ups could be a focal point for further analysis of software sales. More specifically – if revenue was introduced to the picture – Xbox's software and hardware sales could be contrasted with their sales from their exclusivity era. Additionally, Sony's strategy of releasing games on PC could be compared with Nintendo's decision to remain fully exclusive with their games. Here are just two elements that might be investigated with modern game sales data.

## How to Reproduce

1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/gregorut/videogamesales) and place it in the `Data/` folder.
2. Run the SQL scripts in the `SQL Scripts/` directory using MySQL.
3. Export the cleaned tables as CSV files.
4. Load the CSVs into Tableau to recreate the visualizations.
