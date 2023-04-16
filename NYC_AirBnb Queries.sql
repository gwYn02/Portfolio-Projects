--Table Creation
CREATE TABLE nyc_airbnb (
    id INTEGER,
    name VARCHAR(255),
    host_id INTEGER,
    host_name VARCHAR(255),
    neighbourhood_group VARCHAR(255),
    neighbourhood VARCHAR(255),
    latitude FLOAT,
    longitude FLOAT,
    room_type VARCHAR(255),
    price INTEGER,
    minimum_nights INTEGER,
    number_of_reviews INTEGER,
    last_review DATE,
    reviews_per_month FLOAT,
    calculated_host_listings_count INTEGER,
    availability_365 INTEGER
);

--Importing Table
COPY nyc_airbnb FROM 'C:\Users\gwyns\Downloads\NYCairbnb\AB_NYC_2019.csv' DELIMITER ',' CSV HEADER;

--Altering Tables
ALTER TABLE nyc_airbnb
ADD COLUMN distance_from_center FLOAT;

--Updating and Casting Column
UPDATE nyc_airbnb
SET distance_from_center = (6371 * acos(cos(radians(40.7128)) * cos(radians(latitude)) * cos(radians(longitude) - radians(-74.0060)) + sin(radians(40.7128)) * sin(radians(latitude))));

UPDATE nyc_airbnb
SET distance_from_center = ROUND(distance_from_center::NUMERIC, 2);

SELECT * FROM nyc_airbnb;

--Most Expensive Listing by Neighbourhood_group
SELECT neighbourhood_group, MAX(price) AS highest_price
FROM nyc_airbnb
GROUP BY neighbourhood_group;

--Cheapest Listing by Neighbourhood_group
SELECT neighbourhood_group, MIN(price) AS lowest_price
FROM nyc_airbnb
GROUP BY neighbourhood_group;

--Most Expensive Listing by Neighbourhood_group
SELECT neighbourhood_group, MAX(price) AS highest_price
FROM nyc_airbnb
GROUP BY neighbourhood_group;

--Average Price per Neighbourhood Group
SELECT neighbourhood_group, ROUND(AVG(price), 2) AS average_price
FROM nyc_airbnb
GROUP BY neighbourhood_group;

--Number of Listing per Neighbourhood
SELECT neighbourhood, COUNT(*) AS count_of_listings
FROM nyc_airbnb
GROUP BY neighbourhood
ORDER BY count_of_listings DESC;

--Host with Most Listings in each neighbourhood_group
SELECT a.neighbourhood_group, a.host_name, a.count_of_listings
FROM (	SELECT neighbourhood_group, host_name, COUNT(*) AS count_of_listings
		FROM nyc_airbnb
	 	GROUP BY neighbourhood_group, host_name) a
INNER JOIN(
		SELECT neighbourhood_group, MAX(count_of_listings) AS maxcount
		FROM (
			SELECT neighbourhood_group, host_name, COUNT(*) AS count_of_listings
			FROM nyc_airbnb
	 		GROUP BY neighbourhood_group, host_name) b
GROUP BY neighbourhood_group) c
ON a.neighbourhood_group = c.neighbourhood_group
AND a.count_of_listings = c.maxcount
ORDER BY a.count_of_listings DESC;

--Number of Listing per Room_type in Brooklyn & Manhattan
SELECT neighbourhood_group, room_type, COUNT(*) AS number_of_listings
FROM nyc_airbnb
WHERE neighbourhood_group = 'Manhattan' OR neighbourhood_group ='Brooklyn'
GROUP BY neighbourhood_group, room_type;

--Even numbered Listings in Manhattan
SELECT id, name, host_name, neighbourhood_group
FROM nyc_airbnb
WHERE id % 2 = 0
ORDER BY id;

--Percentage of listings w/ greater than 180 days availability
SELECT ROUND(AVG(CASE
				 WHEN availability_365 > 180 THEN 1 
				 ELSE 0
				 END) * 100, 2) AS percent_avail_gt_180
FROM nyc_airbnb;

--Type 5 most reviewed listings
SELECT name, host_name, number_of_reviews
FROM nyc_airbnb
ORDER BY number_of_reviews DESC
LIMIT 5;

--Available listings per MONTH
SELECT CASE EXTRACT(MONTH FROM last_review)
			WHEN 1 THEN 'January'
			WHEN 2 THEN 'February'
			WHEN 3 THEN 'March'
			WHEN 4 THEN 'April'
			WHEN 5 THEN 'May'
			WHEN 6 THEN 'June'
			WHEN 7 THEN 'July'
			WHEN 8 THEN 'August'
			WHEN 9 THEN 'September'
			WHEN 10 THEN 'October'
			WHEN 11 THEN 'November'
			WHEN 12 THEN 'December'
			ELSE 'No info'
		END AS month,
		COUNT(*) AS num_listings
FROM nyc_airbnb
GROUP BY month
ORDER BY MONTH;