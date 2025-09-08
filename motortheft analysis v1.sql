CREATE DATABASE motor_theft;

USE motor_theft;

CREATE TABLE make_details (
	make_id INT PRIMARY KEY,
    make_name VARCHAR(100),
    make_type VARCHAR (100))
    
CREATE TABLE Stolen_vehicles (
	vehicle_id INT PRIMARY KEY,
    vehicle_type VARCHAR(100),
    model_year INT,
    vehicle_desc VARCHAR(100),
    color VARCHAR(50),
    date_stolen DATE,
    location_id INT)
    
CREATE TABLE locations (
	location_id INT,
    region VARCHAR(50),
    country VARCHAR(50),
    population INT,
    density FLOAT)
    
ALTER TABLE locations MODIFY density DECIMAL(10,2);

ALTER TABLE locations MODIFY location_id INT PRIMARY KEY;

DESC locations;
DESC stolen_vehicles;

ALTER TABLE stolen_vehicles ADD make_id INT AFTER vehicle_type;

-- DELETE FROM stolen_vehicles;

 -- SHOW VARIABLES LIKE 'secure_file_priv';

SELECT * FROM stolen_vehicles;

-- 2. Data Quality & Cleaning
-- Identify missing / inconsistent values

SELECT
	SUM(CASE WHEN make_id IS NULL THEN 1 ELSE 0 END) AS Missing_makeID,
    SUM(CASE WHEN location_id IS NULL THEN 1 ELSE 0 END) AS Missing_locationID,
    SUM(CASE WHEN model_year IS NULL OR TRIM(model_year) ="" THEN 1 ELSE 0 END) AS Missing_modelyear,
    SUM(CASE WHEN date_stolen IS NULL THEN 1 ELSE 0 END) AS Missing_Datestolen
FROM stolen_vehicles;

-- Invalid model years (future years or very old)

SELECT * 
FROM 
	stolen_vehicles
WHERE
	model_year >2025 OR model_year < 1950;
	
-- Check duplicate vehicle records

SELECT
	vehicle_id, COUNT(*) AS Record_count
FROM
	stolen_vehicles
GROUP BY
	vehicle_id
HAVING
	COUNT(*) > 1 ;

-- Validate foreign key references

SELECT DISTINCT 
	s.make_id
FROM
	stolen_vehicles s 
LEFT JOIN 
	make_details m 
ON s.make_id = m.make_id
WHERE
	m.make_id IS NULL;
    
SELECT DISTINCT 
	s.location_id
FROM
	stolen_vehicles s 
LEFT JOIN
	locations l 
ON s.location_id = l.location_id
WHERE
	s.location_id IS NULL;

-- 3. Exploratory Analysis

-- Total number of vehicles stolen by year and month

SELECT
	YEAR(date_stolen) Year,
    MONTHNAME(date_stolen) Month,
    COUNT(vehicle_id) Total_vehicles
FROM
	stolen_vehicles
GROUP BY
	YEAR(date_stolen), MONTHNAME(date_stolen)
ORDER BY
	YEAR(date_stolen), MONTHNAME(date_stolen);

-- Breakdown of thefts by vehicle type (cars, trailers, motorcycles, etc.)

SELECT
	vehicle_type AS Vehicle_Type,
    COUNT(*) AS Total_vehicle,
    ROUND((COUNT(*) * 100 / (SELECT COUNT(*) FROM stolen_vehicles)),2) AS Percentage_share
FROM
	stolen_vehicles
GROUP BY
	vehicle_type
ORDER BY
	COUNT(vehicle_type) DESC;

-- Most common colors of stolen vehicles

SELECT
	color AS Color_Name,
    COUNT(*) AS Total_color,
    ROUND((COUNT(*) * 100 / (SELECT COUNT(*) FROM stolen_vehicles)),2) AS Percentage_Share
FROM
	stolen_vehicles
GROUP BY
	color
ORDER BY
	Total_color DESC;
    
 -- Distribution of thefts by model year (are newer or older vehicles targeted?)
 
 SELECT
	model_year AS Model_Year,
    COUNT(model_year) AS Total_count
FROM
	stolen_vehicles
GROUP BY
	model_year
ORDER BY
	model_year;
    
-- Bucket years into categories (Old vs New):

SELECT
	CASE
		WHEN model_year <2000 THEN 'Before 2000'
        WHEN model_year > 2000 AND model_year < 2010 THEN '2000 - 2010'
        WHEN model_year >2010 AND model_year < 2020 THEN '2010 - 2020'
        ELSE '2020+'
	END AS Category,
    COUNT(*) AS Total_Count,
    ROUND((COUNT(*) * 100 / (SELECT COUNT(*) FROM stolen_vehicles)),2) AS Percentage_share
FROM
	stolen_vehicles
GROUP BY
	Category
ORDER BY
	Total_Count DESC;
    
-- year-over-year comparison

WITH yearly_counts AS(
	SELECT
		YEAR(date_stolen) AS Year,
        COUNT(vehicle_id) AS Total_vehicle
	FROM 
		stolen_vehicles
	GROUP BY
		YEAR(date_stolen))

SELECT
	Year,
    Total_vehicle,
    LAG(Total_vehicle) OVER (ORDER BY Year) AS Prev_Year_Total,
    (Total_vehicle - LAG(Total_vehicle) OVER (ORDER BY Year)) AS Yearly_Change,
    ROUND((Total_vehicle - LAG(Total_vehicle) OVER (ORDER BY Year)) / Total_Vehicle , 2) AS Yearly_Chang_Percentage
FROM
	yearly_counts
ORDER BY 
	Year;
    
-- 4. Regional Insights

-- Top 5 regions with the highest theft counts.

SELECT 
	region AS Region,
    COUNT(s.vehicle_id) AS Total_vehicle
FROM
	locations l 
JOIN
	stolen_vehicles s 
ON 
	l.location_id = s.location_id
GROUP BY
	Region
ORDER BY
	Total_vehicle DESC;

-- Theft rate per 100,000 people in each region (using population field).

SELECT
	region AS Region_name,
    COUNT(s.vehicle_id) AS Total_thefts,
    population AS Total_population,
    ROUND((COUNT(s.vehicle_id)/l.population) * 100000,2) AS Theft_Rate_per100000_people
FROM
	locations l 
JOIN
	stolen_vehicles s 
ON
	l.location_id = s.location_id
GROUP BY
	l.region, l.population
ORDER BY
	Theft_Rate_per100000_people;
    
--  Identify regions where theft density is disproportionately high compared to population density.

SELECT
	region AS Region_name,
    COUNT(s.vehicle_id) AS Total_thefts,
    density AS Region_density,
    ROUND(COUNT(s.vehicle_id)/l.density , 2) AS Theft_Density
FROM
	locations l 
JOIN
	stolen_vehicles s 
ON 
	l.location_id = s.location_id
GROUP BY
	l.region, l.density
ORDER BY 
	Theft_Density DESC;
    
-- 5. Vehicle Manufacturer Analysis

-- Top 10 most stolen vehicle makes

SELECT 
	m.make_id AS Make_id,
    m.make_name AS Make_name,
    COUNT(s.vehicle_id) AS Total_thefts
FROM
	make_details m
JOIN
	stolen_vehicles s
ON
	m.make_id = s.make_id
GROUP BY
	m.make_id, m.make_name
ORDER BY
	Total_thefts DESC
LIMIT 10;

-- Theft trends over time for the top 5 makes.

WITH top_makes AS(
	SELECT
		m.make_id AS Make_id,
		m.make_name AS Make_name
	FROM
		make_details m 
	JOIN
		stolen_vehicles s 
	ON 
		m.make_id = s.make_id
	GROUP BY
		m.make_id, m.make_name
	ORDER BY
		COUNT(s.vehicle_id) DESC
	LIMIT 5 )
    
SELECT
	YEAR(s.date_stolen) AS Year,
    m.make_name AS Make_name,
    COUNT(s.vehicle_id) AS Total_theft
FROM
	make_details m 
JOIN stolen_vehicles s ON m.make_id = s.make_id
JOIN top_makes tm on m.make_id = tm.make_id
GROUP BY
	YEAR(s.date_stolen), m.make_name
ORDER BY
	Year, Total_Theft DESC;
    
-- Compare standard vs other make types in theft frequency.

SELECT
	m.make_type AS Make_type_name,
    COUNT(s.vehicle_id) AS Total_theft
FROM 
	make_details m
JOIN
	stolen_vehicles s
ON
	m.make_id = s.make_id
GROUP BY
	m.make_type 
ORDER BY
	Total_theft;
    
-- 6. Temporal Analysis

-- Peak months and seasons for vehicle thefts

SELECT
	MONTHNAME(date_stolen) AS Month,
    COUNT(vehicle_id) AS Total_theft
FROM
	stolen_vehicles
GROUP BY
	MONTHNAME(date_stolen)
ORDER BY
	Month;
    
SELECT
	CASE 
		WHEN MONTH(date_stolen) IN (12,1,2) THEN "Winter"
        WHEN MONTH(date_stolen) IN (3,4,5) THEN "Spring"
        WHEN MONTH(date_stolen) IN (6,7,8) THEN "Summer"
        WHEN MONTH(date_stolen) IN (9,10,11) THEN "Fall"
	END AS Season,
    COUNT(vehicle_id) AS Total_theft
FROM
	stolen_vehicles
GROUP BY
	Season
ORDER BY
	Total_theft DESC;
    
-- Weekday vs weekend theft distribution

SELECT
	DAYNAME(date_stolen) AS Day_Name,
    COUNT(vehicle_id) AS Total_theft
FROM
	stolen_vehicles
GROUP BY
	DAYNAME(date_stolen)
ORDER BY
	Day_Name, Total_theft DESC;
    
SELECT
	CASE
		WHEN DAYOFWEEK(date_stolen) IN (1,7) THEN "Week End"
        ELSE "Week Day"
	END AS Day_Type,
    COUNT(vehicle_id) AS Total_theft
FROM 
	stolen_vehicles
GROUP BY
	Day_Type
ORDER BY
	Total_theft;

-- 7. Advanced Business-Oriented KPIs

-- Hotspot Identification: Region + Make combinations most at risk (e.g., “Toyota Hilux thefts are concentrated in Auckland”).    

SELECT
	l.region AS Region_Name,
    m.make_type AS Make_type,
    COUNT(s.vehicle_id) AS Total_theft
FROM
	stolen_vehicles s 
JOIN locations l ON l.location_id = s.location_id
JOIN make_details m ON m.make_id = s.make_id
GROUP BY
	l.region, m.make_type
ORDER BY
	Total_theft DESC;
    

SELECT
	l.region AS Region_Name,
    m.make_type AS Make_type,
    COUNT(s.vehicle_id) AS Total_theft,
    ROUND(COUNT(s.vehicle_id) * 100 / SUM(COUNT(s.vehicle_id)) OVER (PARTITION BY l.region),2) AS Percentage_in_region
FROM
	stolen_vehicles s 
JOIN locations l ON l.location_id = s.location_id
JOIN make_details m ON m.make_id = s.make_id
GROUP BY
	l.region, m.make_type
ORDER BY
	l.region, Total_theft DESC;

-- Subquery-based Tasks

-- Find the region with the highest thefts

SELECT
	l.region AS Region_name,
    COUNT(*) AS Total_thefts
FROM
	locations l 
JOIN
	stolen_vehicles s 
ON l.location_id = s.location_id
GROUP BY l.region
HAVING COUNT(*) = (
	SELECT MAX(Theft_count)
	FROM (
		SELECT COUNT(*) AS Theft_count
        FROM locations l2
        JOIN stolen_vehicles s2
        ON l2.location_id = s2.location_id
        GROUP BY l2.region
        ) AS t
        );
        
-- List makes with thefts above the overall average thefts per make

SELECT 
	m.make_name AS Make_name,
    COUNT(s.vehicle_id) AS Total_theft
FROM 
	make_details m 
JOIN
	stolen_vehicles s 
ON m.make_id = s.make_id
GROUP BY m.make_name
HAVING COUNT(s.vehicle_id) > (
	SELECT AVG(Theft_count)
    FROM (
		SELECT COUNT(vehicle_id) AS Theft_count
        FROM stolen_vehicles
        GROUP BY make_id) AS t
        );

-- CTE-based Tasks

-- Yearly theft totals with growth % compared to the previous year

WITH Yearly AS (
	SELECT
		YEAR(date_stolen) AS Year,
        COUNT(vehicle_id) AS Total_theft
	FROM
		stolen_vehicles
	GROUP BY
		YEAR(date_stolen))
SELECT
	Year,
    Total_theft,
    LAG(Total_theft) OVER (ORDER BY Year) AS Previous_year,
    ROUND(
		(Total_theft - LAG(Total_theft) OVER (ORDER BY Year)) * 100 / LAG(Total_theft) OVER (ORDER BY Year) , 2) AS YOY_Prev_Year_Change
	FROM
		Yearly
	GROUp BY Year;
    
-- Top 3 vehicle makes per region (using ROW_NUMBER)

WITH make_region AS (
	SELECT
		l.region AS Region_name,
        m.make_name AS Make_name,
        COUNT(s.vehicle_id) AS Total_theft,
        ROW_NUMBER() OVER (PARTITION BY l.region ORDER BY COUNT(s.vehicle_id) DESC) AS rn
	FROM
		stolen_vehicles s 
	JOIN locations l ON l.location_id = s.location_id
    JOIN make_details m ON m.make_id = s.make_id
    GROUP BY l.region, m.make_name
    )
SELECT
	Region_name,
    Make_name,
    Total_theft
FROM
	make_region
WHERE rn <=3;

-- Window Function-based Tasks

-- Cumulative thefts over time

SELECT
	YEAR(date_stolen) AS Year,
    COUNT(vehicle_id) AS Total_theft,
    SUM(COUNT(vehicle_id)) OVER (ORDER BY YEAR(date_stolen)) AS CUM_Total_theft
FROM
	stolen_vehicles
GROUP BY
	YEAR(date_stolen);
    
-- Percentage contribution of each make within its region

SELECT
	l.region AS Region_name,
    m.make_name AS Make_name,
    COUNT(s.vehicle_id) AS Total_theft,
    ROUND(
		(COUNT(s.vehicle_id) * 100)/SUM(COUNT(s.vehicle_id)) OVER (PARTITION BY l.region), 2) AS Percentage_region
FROM
	stolen_vehicles s
JOIN locations l ON l.location_id = s.location_id
JOIN make_details m ON m.make_id = s.make_id
GROUP BY l.region, m.make_name
ORDER BY l.region, Total_theft DESC;











