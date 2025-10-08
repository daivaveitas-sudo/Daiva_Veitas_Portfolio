




DELIMITER $$


CREATE PROCEDURE Copy_and_clean_data()
BEGIN

# Make copy of table WITH Timestamp and no indexes
# First,  create table
CREATE TABLE IF NOT EXISTS `ushouseholdincome_cleaned` (
  `row_id` int DEFAULT NULL,
  `id` int DEFAULT NULL,
  `State_Code` int DEFAULT NULL,
  `State_Name` text,
  `State_ab` text,
  `County` text,
  `City` text,
  `Place` text,
  `Type` text,
  `Primary` text,
  `Zip_Code` int DEFAULT NULL,
  `Area_Code` int DEFAULT NULL,
  `ALand` int DEFAULT NULL,
  `AWater` int DEFAULT NULL,
  `Lat` double DEFAULT NULL,
  `Lon` double DEFAULT NULL,
  `Time_Stamp` TIMESTAMP DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

# Second, insert data with TIMESSTAMP 
	INSERT INTO ushouseholdincome_cleaned
    SELECT *, CURRENT_TIMESTAMP
    FROM auto_data_clean_project.ushouseholdincome;


-- Remove Duplicates
DELETE FROM ushouseholdincome_cleaned 
WHERE 
	row_id IN (
	SELECT row_id
FROM (
	SELECT row_id, id,
		ROW_NUMBER() OVER (
			PARTITION BY id
			ORDER BY id) AS row_num
	FROM ushouseholdincome_cleaned
) duplicates
WHERE 
	row_num > 1
);

-- Fixing some data quality issues by fixing typos and general standardization
UPDATE ushouseholdincome_cleaned
SET State_Name = 'Georgia'
WHERE State_Name = 'georia';

UPDATE ushouseholdincome_cleaned
SET County = UPPER(County);

UPDATE ushouseholdincome_cleaned
SET City = UPPER(City);

UPDATE ushouseholdincome_cleaned
SET Place = UPPER(Place);

UPDATE ushouseholdincome_cleaned
SET State_Name = UPPER(State_Name);

UPDATE ushouseholdincome_cleaned
SET `Type` = 'CDP'
WHERE `Type` = 'CPD';

UPDATE ushouseholdincome_cleaned
SET `Type` = 'Borough'
WHERE `Type` = 'Boroughs';

END $$

DELIMITER ;

CALL Copy_and_clean_data();


SELECT DISTINCT state_name
FROM ushouseholdincome_cleaned;

SELECT row_id, Id
FROM ushouseholdincome_cleaned 
WHERE 
	row_id IN (
	SELECT row_id
FROM (
	SELECT row_id, id,
		ROW_NUMBER() OVER (
			PARTITION BY id
			ORDER BY id) AS row_num
	FROM ushouseholdincome_cleaned
) duplicates
WHERE 
	row_num > 1
);

